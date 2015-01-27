require_relative '../api'

describe PaypalService::API::BillingAgreements do

  PaypalAccountStore = PaypalService::PaypalAccount
  AccountStore = PaypalService::Store::PaypalAccount

  before(:each) do
    # Test version of merchant client
    PaypalService::API::Api.reset!
    @events = PaypalService::API::Api.events
    @api_builder = PaypalService::API::Api.api_builder
    @payments = PaypalService::API::Api.payments
    @billing_agreements = PaypalService::API::Api.billing_agreements

    @process = PaypalService::API::Process.new


    # Test data

    @cid = 10
    @mid = "merchant_id_1"
    @paypal_email = "merchant_1@test.com"
    @paypal_email_admin = "admin_2@test.com"
    @payer_id = "payer_id_1"
    @payer_id_admin = "payer_id_2"
    @billing_agreement_id = "bagrid"

    AccountStore.create(
      {
        person_id: @mid,
        community_id: @cid,
        email: @paypal_email,
        payer_id: @payer_id,
        paypal_username_to: "sharetribe@sharetribe.com",
        request_token: "123456789"
      })
    AccountStore.update(
      {
        person_id: @mid,
        community_id: @cid,
        billing_agreement_id: @billing_agreement_id,
        billing_agreement_request_token: "request-token",
        billing_agreement_paypal_username_to: @paypal_email_admin
      })

    AccountStore.create(
      {
        community_id: @cid,
        email: @paypal_email_admin,
        payer_id: @payer_id_admin,
        paypal_username_to: "sharetribe@sharetribe.com",
        request_token: "123456789"
      })

    @tx_id = 1234

    @req_info = {
      transaction_id: @tx_id,
      item_name: "Item name",
      item_quantity: 1,
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


  context "#charge_commission" do

    before(:each) do
      @payment_total = Money.new(1200, "EUR")
      token = @payments.request(@cid, @req_info)[:data]
      @payments.create(@cid, token[:token])[:data]
      @events.clear

      @commission_info = {
        transaction_id: @tx_id,
        commission_to_admin: Money.new(100, "EUR"),
        minimum_commission: Money.new(50, "EUR"),
        payment_name: "commission payment",
        payment_desc: "commission payment desc"
      }
    end

    it "charges the commission and updates the payment" do
      @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      payment_res = @billing_agreements.charge_commission(@cid, @mid, @commission_info)

      expect(payment_res[:success]).to eq(true)
      expect(payment_res[:data][:commission_payment_id]).not_to be_nil
      expect(payment_res[:data][:commission_status]).to eq(:completed)
      expect(payment_res[:data][:commission_pending_reason]).to eq(:none)

      expect(payment_res[:data][:commission_total]).to eq(Money.new(100, "EUR"))
      expect(payment_res[:data][:commission_fee_total]).not_to be_nil
    end

    it "marks the commission to not applicable when admin is merchant" do
      @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })

      AccountStore.create(
        {
          person_id: @payer_id_admin,
          community_id: @cid,
          payer_id: @payer_id_admin,
          email: @paypal_email,
          paypal_username_to: "sharetribe@sharetribe.com",
          request_token: "123456789"
        })


      AccountStore.update(
        {
          person_id: @payer_id_admin,
          community_id: @cid,
          billing_agreement_id: @billing_agreement_id,
          billing_agreement_request_token: "request-token",
          billing_agreement_paypal_username_to: @paypal_email_admin
        })

      payment_res = @billing_agreements.charge_commission(@cid, @payer_id_admin, @commission_info)

      expect(payment_res[:success]).to eq(true)
      expect(payment_res[:data][:commission_status]).to eq(:seller_is_admin)
    end

    it "marks the commission to not applicable when commission smaller than minimum" do
      @payments.full_capture(@cid, @tx_id, { payment_total: Money.new(2, "EUR") })

      commission_info = {
        transaction_id: @tx_id,
        commission_to_admin: Money.new(47, "EUR"),
        minimum_commission: Money.new(50, "EUR"),
        payment_name: "commission payment",
        payment_desc: "commission payment desc"
      }

      payment_res = @billing_agreements.charge_commission(@cid, @mid, commission_info)

      expect(payment_res[:success]).to eq(true)
      expect(payment_res[:data][:commission_status]).to eq(:below_minimum)
    end

    it "supports async running" do
      @payments.full_capture(@cid, @tx_id, { payment_total: @payment_total })
      SyncDelayedJobObserver.collect!

      process_status = @billing_agreements.charge_commission(@cid, @mid, @commission_info, async: true)[:data]
      expect(process_status[:completed]).to eq(false)

      SyncDelayedJobObserver.process_queue!

      process_status = @process.get_status(process_status[:process_token])[:data]
      payment_res = process_status[:result]

      expect(process_status[:completed]).to eq(true)
      expect(payment_res[:data][:commission_payment_id]).not_to be_nil
      expect(payment_res[:data][:commission_status]).to eq(:completed)
      expect(payment_res[:data][:commission_pending_reason]).to eq(:none)
    end
  end
end
