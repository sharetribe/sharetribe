module TransactionService::Gateway
  class BraintreeAdapter < GatewayAdapter

    PaymentModel = ::Payment

    def implements_process(process)
      [:none, :preauthorize, :postpay].include?(process)
    end

    def create_payment(tx:, gateway_fields:, prefer_async: nil)
      payment_gateway_id = BraintreePaymentGateway.where(community_id: tx[:community_id]).pluck(:id).first
      payment = BraintreePayment.create(
        {
          transaction_id: tx[:id],
          community_id: tx[:community_id],
          payment_gateway_id: payment_gateway_id,
          status: :pending,
          payer_id: tx[:starter_id],
          recipient_id: tx[:listing_author_id],
          currency: "USD",
          sum: tx[:unit_price] * tx[:listing_quantity]})

      result = BraintreeSaleService.new(payment, gateway_fields).pay(false)

      if !result.success?
        SyncCompletion.new(Result::Error.new(result.message))
      end

      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def reject_payment(tx:, reason: nil)
      result = BraintreeService::Payments::Command.void_transaction(tx[:id], tx[:community_id])

      if !result.success?
        SyncCompletion.new(Result::Error.new(result.message))
      end

      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def complete_preauthorization(tx:)
      result = BraintreeService::Payments::Command.submit_to_settlement(tx[:id], tx[:community_id])

      if !result.success?
        SyncCompletion.new(Result::Error.new(result.message))
      end

      SyncCompletion.new(Result::Success.new({result: true}))
    end

    def get_payment_details(tx:)
      payment_total = Maybe(PaymentModel.where(transaction_id: tx[:id]).first).total_sum.or_else(nil)
      total_price = tx[:unit_price] * 1 # TODO fixme for booking (model.listing_quantity)
      { payment_total: payment_total,
        total_price: total_price,
        charged_commission: nil, # TODO Apparently this value is not used in case of BT/Checkout?
        payment_gateway_fee: nil }
    end

  end
end
