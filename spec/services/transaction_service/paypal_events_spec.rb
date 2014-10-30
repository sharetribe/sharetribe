require 'spec_helper'

describe TransactionService::PaypalEvents do

  TokenStore = PaypalService::Store::Token

  context "#request_cancelled" do
    before(:each) do
      @cid = 4
      @transaction = FactoryGirl.create(:transaction, community_id: 4, current_state: "initiated")
      @token_code = SecureRandom.uuid
      TokenStore.create({
          community_id: @cid,
          token: @token_code,
          transaction_id: @transaction.id,
          merchant_id: @transaction.starter_id,
          item_name: "item name",
          item_quantity: 1,
          item_price: Money.new(22000, "EUR"),
          express_checkout_url: "htts://test.com/#{@token_code}"
        })
      @token = TokenStore.get(@cid, @token_code)
    end

    it "removes transaction associated with the cancelled token" do
      TransactionService::PaypalEvents.request_cancelled(@token)

      expect(Transaction.count).to eq(0)
    end

    it "calling with token that doesn't match a transaction is a no-op" do
      already_removed = @token.merge({transaction_id: 987654321})
      TransactionService::PaypalEvents.request_cancelled(already_removed)

      expect(Transaction.count).to eq(1)
    end
  end
end
