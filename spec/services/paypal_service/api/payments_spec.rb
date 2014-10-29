require 'spec_helper'

require_relative '../test_events'
require_relative '../test_logger'
require_relative '../test_merchant'

describe PaypalService::API::Payments do

  TokenStore = PaypalService::Store::Token
  PaymentStore = PaypalService::Store::PaypalPayment

  before(:each) do
    @events = PaypalService::TestEvents.new
    @payments = PaypalService::API::Payments.new(
      @events,
      PaypalService::TestMerchant.build,
      PaypalService::TestLogger.new)

    @cid = 10
    @mid = "merchant_id_1"
    @paypal_email = "merchant_1@test.com"
    @payer_id = "payer_id_1"

    PaypalService::PaypalAccount::Command.create_personal_account(
      @mid,
      @cid,
      { email: @paypal_email, payer_id: @payer_id })

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
  end

  context "#request and #request_cancel" do
    it "saves token info" do
      response = @payments.request(@cid, @req_info)
      token = PaypalService::Store::Token.get_for_transaction(@cid, @tx_id)

      expect(token[:community_id]).to eq @cid
      expect(token[:token]).to eq response[:data][:token]
      expect(token[:transaction_id]).to eq @req_info[:transaction_id]
      expect(token[:merchant_id]).to eq @req_info[:merchant_id]
      expect(token[:item_name]).to eq @req_info[:item_name]
      expect(token[:item_quantity]).to eq @req_info[:item_quantity]
      expect(token[:item_price]).to eq @req_info[:item_price]
    end

    it "cancel deletes token and fires request_cancelled event" do
      @payments.request(@cid, @req_info)
      token = PaypalService::Store::Token.get_for_transaction(@cid, @tx_id)

      @payments.request_cancel(@cid, token[:token])

      expect(PaypalToken.count).to eq 0
      expect(@events.received_events[:request_cancelled].length).to eq 1
      expect(@events.received_events[:request_cancelled].first).to eq token
    end

    it "cancel fires no events for non-existent token" do
      result = @payments.request_cancel(@cid, "foo_bar_token")

      expect(result[:success]).to eq false
      expect(PaypalToken.count).to eq 0
      expect(@events.received_events[:request_cancelled].length).to eq 0
    end
  end

  context "#create" do
    it "creates, authorizes and saves the new payment" do
      token = @payments.request(@cid, @req_info)[:data]

      payment_res = @payments.create(@cid, token[:token])

      payment = PaymentStore.get(@cid, @tx_id)
      expect(payment_res.success).to eq(true)
      expect(payment).not_to be_nil
      expect(payment_res[:data][:payment_status]).to eq(:pending)
      expect(payment_res[:data][:pending_reason]).to eq(:authorization)
      expect(payment_res[:data][:order_id]).not_to be_nil
      expect(payment_res[:data][:order_total]).to eq(@req_info[:order_total])
      expect(payment_res[:data][:authorization_id]).not_to be_nil
      expect(payment_res[:data][:authorization_total]).to eq(@req_info[:order_total])
    end

    it "raises payment_created event followed by payment_updated" do
      token = @payments.request(@cid, @req_info)[:data]
      payment_res = @payments.create(@cid, token[:token])

      payment = PaymentStore.get(@cid, @tx_id)
      expect(@events.received_events[:payment_created].length).to eq(1)
      expect(@events.received_events[:payment_updated].length).to eq(1)
      expect(@events.received_events[:payment_updated].first).to eq(payment_res[:data])
    end

    it "deletes request token" do
      token = @payments.request(@cid, @req_info)[:data]
      @payments.create(@cid, token[:token])

      expect(PaypalToken.count).to eq 0
    end

    it "returns failure and fires no events when called with non-existent token" do
      res = @payments.create(@cid, "not_a_real_token")

      expect(res.success).to eq(false)
      expect(@events.received_events[:payment_created].length).to eq(0)
      expect(@events.received_events[:payment_updated].length).to eq(0)
    end
  end

end
