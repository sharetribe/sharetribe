require "spec_helper"

describe PaypalService::API::Payments do

  let(:token_store) { PaypalService::Store::Token }
  let(:payment_store) { PaypalService::Store::PaypalPayment }
  let(:account_store) { PaypalService::Store::PaypalAccount }

  before(:each) do
    # Test version of merchant client
    PaypalService::API::Api.reset!
    @events = PaypalService::API::Api.build_test_events
    @api_builder = PaypalService::API::Api.api_builder
    @payments = PaypalService::API::Api.build_test_payments(events: @events)

    @process = PaypalService::API::Process.new


    # Test data

    @cid = 10
    @mid = "merchant_id_1"
    @paypal_email = "merchant_1@test.com"
    @payer_id = "payer_id_1"

    account_store.create(opts:
      {
        active: true,
        person_id: @mid,
        community_id: @cid,
        email: @paypal_email,
        payer_id: @payer_id,
        order_permission_paypal_username_to: "sharetribe@sharetribe.com",
        order_permission_request_token: "123456789"
      })

    @tx_id = 1234

    @req_info = {
      transaction_id: @tx_id,
      payment_action: :order,
      item_name: "Item name",
      item_quantity: 1,
      item_total: Money.new(1200, "EUR"),
      item_price: Money.new(1200, "EUR"),
      merchant_id: @mid,
      order_total: Money.new(1200, "EUR"),
      success: "https://www.test.com/success",
      cancel: "https://www.test.com/cancel"
    }

    @req_info_auth = {
      transaction_id: @tx_id,
      payment_action: :authorization,
      item_name: "Item name",
      item_quantity: 1,
      item_total: Money.new(1200, "EUR"),
      item_price: Money.new(1200, "EUR"),
      merchant_id: @mid,
      order_total: Money.new(1200, "EUR"),
      success: "https://www.test.com/success",
      cancel: "https://www.test.com/cancel"
    }

    SyncDelayedJobObserver.reset!
  end

  after(:each) do
    # Do not leave before an active synchronous delayed job runner
    SyncDelayedJobObserver.reset!
  end

  context "#request and #request_cancel" do
    it "saves token info" do
      response = @payments.request(@cid, @req_info)
      token = PaypalService::Store::Token.get_for_transaction(@cid, @tx_id)

      expect(token[:community_id]).to eq @cid
      expect(token[:token]).to eq response[:data][:token]
      expect(token[:transaction_id]).to eq @req_info[:transaction_id]
      expect(token[:payment_action]).to eq :order
      expect(token[:merchant_id]).to eq @req_info[:merchant_id]
      expect(token[:item_name]).to eq @req_info[:item_name]
      expect(token[:item_quantity]).to eq @req_info[:item_quantity]
      expect(token[:item_price]).to eq @req_info[:item_price]
    end

    it "saves token info, using payment_action :authorization" do
      response = @payments.request(@cid, @req_info_auth)
      token = PaypalService::Store::Token.get_for_transaction(@cid, @tx_id)

      expect(token[:community_id]).to eq @cid
      expect(token[:token]).to eq response[:data][:token]
      expect(token[:transaction_id]).to eq @req_info[:transaction_id]
      expect(token[:payment_action]).to eq :authorization
      expect(token[:merchant_id]).to eq @req_info[:merchant_id]
      expect(token[:item_name]).to eq @req_info[:item_name]
      expect(token[:item_quantity]).to eq @req_info[:item_quantity]
      expect(token[:item_price]).to eq @req_info[:item_price]
    end

    it "tries the paypal api call at least 3 times in case of 10001" do
      @api_builder.will_fail(2, "10001")
      response = @payments.request(@cid, @req_info)

      expect(response.success).to eq(true)
    end

    it "cancel deletes token and fires request_cancelled event" do
      @payments.request(@cid, @req_info)
      token = PaypalService::Store::Token.get_for_transaction(@cid, @tx_id)

      @payments.request_cancel(@cid, token[:token])

      expect(PaypalToken.count).to eq 0
      expect(@events.received_events[:request_cancelled].length).to eq 1
      expect(@events.received_events[:request_cancelled].first).to eq([:success, token])
    end

    it "cancel fires no events for non-existent token" do
      result = @payments.request_cancel(@cid, "foo_bar_token")

      expect(result[:success]).to eq false
      expect(PaypalToken.count).to eq 0
      expect(@events.received_events[:request_cancelled].length).to eq 0
    end

    it "supports async running" do
      SyncDelayedJobObserver.collect!

      response = @payments.request(@cid, @req_info, force_sync: false)
      process_status_res = @process.get_status(response[:data][:process_token])
      process_status = process_status_res[:data]

      expect(process_status_res[:success]).to eq(true)
      expect(process_status[:completed]).to eq(false)
      expect(process_status[:result]).to be_nil

      SyncDelayedJobObserver.process_queue!

      process_status = @process.get_status(response[:data][:process_token])[:data]
      payment_res = process_status[:result][:data]

      expect(payment_res[:token]).not_to be_nil
      expect(payment_res[:transaction_id]).to eq(@req_info[:transaction_id])
    end

  end

  context "#create" do
    it "creates, authorizes and saves the new payment" do
      token = @payments.request(@cid, @req_info)[:data]

      payment_res = @payments.create(@cid, token[:token])

      payment = payment_store.get(@cid, @tx_id)
      expect(payment_res.success).to eq(true)
      expect(payment).not_to be_nil
      expect(payment_res[:data][:payment_status]).to eq(:pending)
      expect(payment_res[:data][:pending_reason]).to eq(:authorization)
      expect(payment_res[:data][:order_id]).not_to be_nil
      expect(payment_res[:data][:order_total]).to eq(@req_info[:order_total])
      expect(payment_res[:data][:authorization_id]).not_to be_nil
      expect(payment_res[:data][:authorization_total]).to eq(@req_info[:order_total])
    end

    it "creates authorized new payment and saves it, payment_action :authorization" do
      token = @payments.request(@cid, @req_info_auth)[:data]

      payment_res = @payments.create(@cid, token[:token])

      payment = payment_store.get(@cid, @tx_id)
      expect(payment_res.success).to eq(true)
      expect(payment).not_to be_nil
      expect(payment_res[:data][:payment_status]).to eq(:pending)
      expect(payment_res[:data][:pending_reason]).to eq(:authorization)
      expect(payment_res[:data][:order_id]).to eq(nil)
      expect(payment_res[:data][:order_total]).to eq(nil)
      expect(payment_res[:data][:authorization_id]).not_to be_nil
      expect(payment_res[:data][:authorization_total]).to eq(@req_info_auth[:order_total])
    end

    it "returns error with parseable error_code when payment needs review" do
      token = @payments.request(@cid, @req_info_auth.merge({item_name: "require-payment-review"}))[:data]

      payment_res = @payments.create(@cid, token[:token])

      payment = payment_store.get(@cid, @tx_id)
      expect(payment_res.success).to eq(false)
      expect(payment_res.data[:error_code]).to eq(:"payment-review")
      expect(payment[:pending_reason]).to eq(:"payment-review")
    end

    it "triggers payment_created event followed by payment_updated" do
      token = @payments.request(@cid, @req_info)[:data]
      payment_res = @payments.create(@cid, token[:token])

      payment = payment_store.get(@cid, @tx_id)
      expect(@events.received_events[:payment_created].length).to eq(1)
      expect(@events.received_events[:payment_updated].length).to eq(1)
      expect(@events.received_events[:payment_updated].first).to eq([:success, payment_res[:data]])
    end

    it "triggers payment_created event only, payment_action :authorization" do
      token = @payments.request(@cid, @req_info_auth)[:data]
      payment_res = @payments.create(@cid, token[:token])

      expect(@events.received_events[:payment_created].length).to eq(1)
      expect(@events.received_events[:payment_updated].length).to eq(0)
      expect(@events.received_events[:payment_created].first).to eq([:success, payment_res[:data]])
    end

    it "triggers order_details event with shipping info" do
      token = @payments.request(@cid, @req_info.merge(require_shipping_address: true))[:data]
      payment_res = @payments.create(@cid, token[:token])
      order_details = {
        status: "Confirmed",
        city: "city",
        country: "country",
        country_code: "CC",
        name: "name",
        phone: "123456",
        postal_code: "WX1GQ",
        state_or_province: "state",
        street1: "street1",
        street2: "street2"
      }

      expect(@events.received_events[:order_details].length).to eq(1)
      expect(@events.received_events[:order_details].first.second).to include(order_details)
    end

    it "will retry at least 3 times" do
      token = @payments.request(@cid, @req_info)[:data]
      @api_builder.will_fail(2, "10001")
      payment_res = @payments.create(@cid, token[:token])

      expect(payment_res.success).to eq(true)
    end

    it "deletes request token when payment created" do
      token = @payments.request(@cid, @req_info)[:data]
      @payments.create(@cid, token[:token])

      expect(PaypalToken.count).to eq 0
    end

    it "deletes request token when payment created" do
      token = @payments.request(@cid, @req_info_auth)[:data]
      @payments.create(@cid, token[:token])

      expect(PaypalToken.count).to eq 0
    end

    it "returns failure and fires no events when called with non-existent token" do
      res = @payments.create(@cid, "not_a_real_token")

      expect(res.success).to eq(false)
      expect(@events.received_events[:payment_created].length).to eq(0)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end

    it "deletes token and fires request_cancelled after 3 paypal api failures" do
      token = @payments.request(@cid, @req_info)[:data]
      @api_builder.will_fail(3, "10001")
      payment_res = @payments.create(@cid, token[:token])

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:request_cancelled].length).to eq(1)
      expect(@events.received_events[:request_cancelled].first.second[:transaction_id]).to eq(@tx_id)
      expect(PaypalToken.count).to eq(0)
    end

    it "voids payment after 5 authorization failures" do
      token = @payments.request(@cid, @req_info)[:data]
      @api_builder.will_respond_with([:ok, :ok, "10001", "10001", "10001", "10001", "10001", :ok])
      payment_res = @payments.create(@cid, token[:token])
      payment = @payments.get_payment(@cid, @tx_id)[:data]

      expect(payment_res.success).to eq(false)
      expect(payment[:payment_status]).to eq(:voided)
      expect(payment[:pending_reason]).to eq(:none)
      expect(@events.received_events[:payment_created].length).to eq(1)
      expect(@events.received_events[:payment_updated].first.first).to eq(:error)
      expect(@events.received_events[:payment_updated].first.second[:payment_status]).to eq(:voided)
      expect(@events.received_events[:payment_updated].first.second[:pending_reason]).to eq(:none)
    end

    it "keeps token and returns redirect_url in error data upon 10486 error" do
      token = @payments.request(@cid, @req_info)[:data]
      @api_builder.will_fail(1, "10486")
      payment_res = @payments.create(@cid, token[:token])

      expect(payment_res.success).to eq(false)
      expect(payment_res[:data][:redirect_url]).not_to be_nil
      expect(PaypalToken.count).to eq(1)
    end

    it "supports async running" do
      SyncDelayedJobObserver.collect!

      token = @payments.request(@cid, @req_info)[:data]

      process_status = @payments.create(@cid, token[:token], force_sync: false)[:data]
      expect(process_status[:completed]).to eq(false)
      expect(payment_store.get(@cid, @tx_id)).to be_nil

      SyncDelayedJobObserver.process_queue!

      process_status = @process.get_status(process_status[:process_token])[:data]
      payment_res = process_status[:result]

      expect(process_status[:completed]).to eq(true)
      expect(payment_res[:data][:payment_status]).to eq(:pending)
      expect(payment_res[:data][:pending_reason]).to eq(:authorization)
      expect(payment_res[:data][:order_id]).not_to be_nil
      expect(payment_res[:data][:order_total]).to eq(@req_info[:order_total])
      expect(payment_res[:data][:authorization_id]).not_to be_nil
      expect(payment_res[:data][:authorization_total]).to eq(@req_info[:order_total])
    end

  end

  context "#full_capture" do
    before(:each) do
      @payment_total = Money.new(1200, "EUR")
      token = @payments.request(@cid, @req_info_auth)[:data]
      @payments.create(@cid, token[:token])[:data]
      @events.clear
    end

    it "completes the payment with given payment_total" do
      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      expect(payment_res.success).to eq(true)
      expect(payment_res[:data][:payment_status]).to eq(:completed)
      expect(payment_res[:data][:pending_reason]).to eq(:none)
      expect(payment_res[:data][:payment_id]).not_to be_nil
      expect(payment_res[:data][:payment_total]).to eq(@payment_total)
    end

    it "fires payment_updated event" do
      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      expect(@events.received_events[:payment_updated].length).to eq(1)
      expect(@events.received_events[:payment_updated].last).to eq([:success, payment_res[:data]])
    end

    it "will retry at least 5 times in case of 10001" do
      @api_builder.will_fail(4, "10001")
      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      expect(payment_res.success).to eq(true)
    end

    it "returns failure and fires no events if called for non-existent payment" do
      payment_res = @payments.full_capture(@cid, 987654321, { payment_total: @payment_total })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end

    it "only captures a payment once, second time returns failure" do
      @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })
      @events.clear

      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end

    it "voids payment and fires payment_updated after 5 paypal api fails" do
      @api_builder.will_fail(5, "x-timeout")
      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(1)
      expect(@events.received_events[:payment_updated].first.second[:payment_status]).to eq(:voided)
    end

    it "supports async running" do
      SyncDelayedJobObserver.collect!
      process_status = @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total }, force_sync: false)[:data]
      expect(process_status[:completed]).to eq(false)

      SyncDelayedJobObserver.process_queue!

      process_status = @process.get_status(process_status[:process_token])[:data]
      payment_res = process_status[:result]

      expect(process_status[:completed]).to eq(true)
      expect(payment_res[:data][:payment_status]).to eq(:completed)
      expect(payment_res[:data][:pending_reason]).to eq(:none)
      expect(payment_res[:data][:payment_id]).not_to be_nil
      expect(payment_res[:data][:payment_total]).to eq(@payment_total)
    end
  end

  context "#void" do
    before(:each) do
      @payment_total = Money.new(1200, "EUR")
      token = @payments.request(@cid, @req_info)[:data]
      @payments.create(@cid, token[:token])[:data]
      @events.clear
    end

    it "voids an authorized payment" do
      payment_res = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })

      expect(payment_res.success).to eq(true)
      expect(payment_res[:data][:payment_status]).to eq(:voided)
      expect(payment_res[:data][:pending_reason]).to eq(:none)
    end

    it "triggers a payment updated event" do
      payment_res = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })

      expect(@events.received_events[:payment_updated].length).to eq(1)
      expect(@events.received_events[:payment_updated].first).to eq([:success, payment_res[:data]])
    end

    it "will retry at least 5 times" do
      @api_builder.will_fail(4, "x-servererror")
      payment_res = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })

      expect(payment_res.success).to eq(true)
    end

    it "cannot void the same payment twice" do
      @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })
      @events.clear
      payment_res = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end

    it "cannot void a captured payment" do
      @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })
      @events.clear
      payment_res = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(0)
      expect(payment_store.get(@cid, @tx_id)[:payment_status]).to eq(:completed)
    end

    it "does nothing if called for non-existent payment" do
      payment_res = @payments.void(@cid, 987654321, { note: "Voided for testing purposes." })

      expect(payment_res.success).to eq(false)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end

    it "support async running" do
      SyncDelayedJobObserver.collect!
      process_status = @payments.void(@cid, @tx_id, { note: "Voided for testing purposes." }, force_sync: false)[:data]
      expect(process_status[:completed]).to eq(false)

      SyncDelayedJobObserver.process_queue!

      process_status = @process.get_status(process_status[:process_token])[:data]
      payment_res = process_status[:result]

      expect(process_status[:completed]).to eq(true)
      expect(payment_res[:data][:payment_status]).to eq(:voided)
      expect(payment_res[:data][:pending_reason]).to eq(:none)
    end
  end

  context "#get_payment" do
    it "returns payment for given commmunity_id and transaction_id" do
      token = @payments.request(@cid, @req_info)[:data]
      expect(@payments.get_payment(@cid, @tx_id).success).to eq(false)

      payment_res = @payments.create(@cid, token[:token])
      expect(@payments.get_payment(@cid, @tx_id)[:data]).to eq(payment_res[:data])

      payment_res = @payments.full_capture(@cid, @tx_id, { payment_total: Money.new(1200, "EUR") })
      expect(@payments.get_payment(@cid, @tx_id)[:data]).to eq(payment_res[:data])
    end
  end

  context "#retry_and_clean_tokens" do
    it "retries payment and completes if payment now authorized" do
      @payments.request(@cid, @req_info)[:data]

      @payments.retry_and_clean_tokens(1.hour.ago)

      payment = @payments.get_payment(@cid, @tx_id)[:data]
      expect(payment[:payment_status]).to eq(:pending)
      expect(payment[:pending_reason]).to eq(:authorization)
      expect(token_store.get_all.count).to eq(0)
    end

    it "leaves token in place if op fails but clean time limit not reached" do
      @payments.request(@cid, @req_info.merge({item_name: "payment-not-initiated"}))[:data]

      @payments.retry_and_clean_tokens(1.hour.ago)

      expect(@payments.get_payment(@cid, @tx_id)[:success]).to eq(false)
      expect(token_store.get_all.count).to eq(1)
    end

    it "removes token if op fails and clean time limit reached" do
      @payments.request(@cid, @req_info.merge({item_name: "payment-not-initiated"}))[:data]

      @payments.retry_and_clean_tokens(1.hour.from_now)

      expect(@payments.get_payment(@cid, @tx_id)[:success]).to eq(false)
      expect(token_store.get_all.count).to eq(0)
    end

    it "doesn't remove token when op fails, clean time limit reached but payment in :payment-review state" do
      @payments.request(@cid, @req_info_auth.merge({item_name: "require-payment-review"}))[:data]

      @payments.retry_and_clean_tokens(1.hour.from_now)

      expect(@payments.get_payment(@cid, @tx_id)[:data][:pending_reason]).to eq(:"payment-review")
      expect(token_store.get_all.count).to eq(1)
    end
  end

end
