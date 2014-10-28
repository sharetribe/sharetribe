require 'spec_helper'

require_relative '../test_events'
require_relative '../test_logger'
require_relative '../test_merchant'

describe PaypalService::API::Payments do

  before(:each) do
    @payments = PaypalService::API::Payments.new(
      PaypalService::TestEvents.new,
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

  it "#request - saves token info" do
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
end
