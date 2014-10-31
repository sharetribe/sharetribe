require 'spec_helper'

describe TransactionService::PaypalEvents do

  TokenStore = PaypalService::Store::Token
  PaymentStore = PaypalService::Store::PaypalPayment

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
      TransactionService::PaypalEvents.request_cancelled(:api, @token)

      expect(Transaction.count).to eq(0)
    end

    it "calling with token that doesn't match a transaction is a no-op" do
      already_removed = @token.merge({transaction_id: 987654321})
      TransactionService::PaypalEvents.request_cancelled(:api, already_removed)

      expect(Transaction.count).to eq(1)
    end
  end

  context "#payment_updated - initiated => authorized" do
    before(:each) do
      @cid = 4
      @transaction = FactoryGirl.create(:transaction, community_id: 4, current_state: "initiated", payment_gateway: "paypal")

      @authorized_payment = PaymentStore.create(@cid, @transaction.id, {
          payer_id: "sduyfsudf",
          receiver_id: "98ysdf98ysdf",
          pending_reason: "authorization",
          order_id: SecureRandom.uuid,
          order_date: Time.now,
          order_total: Money.new(22000, "EUR"),
        })
    end

    it "transitions transaction to preauthorized state" do
      TransactionService::PaypalEvents.payment_updated(:api, @authorized_payment)

      tx = MarketplaceService::Transaction::Query.transaction(@transaction.id)
      expect(tx[:status]).to eq("preauthorized")
    end

    it "is safe to call for non-existent transaction" do
      no_matching_tx = @authorized_payment.merge({transaction_id: 987654321 })
      TransactionService::PaypalEvents.payment_updated(:api, no_matching_tx)

      tx = MarketplaceService::Transaction::Query.transaction(@transaction.id)
      expect(tx[:status]).to eq("initiated")
    end
  end

  context "#payment_updated - initiated => voided" do
    before(:each) do
      @cid = 4
      @transaction = FactoryGirl.create(:transaction, community_id: 4, current_state: "initiated", payment_gateway: "paypal")

      PaymentStore.create(@cid, @transaction.id, {
          payer_id: "sduyfsudf",
          receiver_id: "98ysdf98ysdf",
          pending_reason: "authorization",
          order_id: SecureRandom.uuid,
          order_date: Time.now,
          order_total: Money.new(22000, "EUR"),
        })
      @voided_payment = PaymentStore.update(@cid, @transaction.id,  {
          pending_reason: :none,
          payment_status: :voided
        })
    end

    it "removes the associated transaction" do
      TransactionService::PaypalEvents.payment_updated(:api, @voided_payment)

      expect(Transaction.count).to eq(0)
    end

    it "is safe to call for non-existent transaction" do
      no_matching_tx = @voided_payment.merge({transaction_id: 987654321 })
      TransactionService::PaypalEvents.payment_updated(:api, no_matching_tx)

      expect(Transaction.count).to eq(1)
    end
  end
end
