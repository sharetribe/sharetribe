module TransactionService::Gateway

  # Stub checkout adapter, not expected to be called at this point.
  class CheckoutAdapter < GatewayAdapter

    PaymentModel = ::Payment

    def implements_process(process)
      [:none, :postpay].include?(process)
    end

    def get_payment_details(tx:)
      payment_total = Maybe(PaymentModel.where(transaction_id: tx[:id]).first).total_sum.or_else(nil)
      total_price = tx[:unit_price] * tx[:listing_quantity]
      { payment_total: payment_total,
        total_price: total_price,
        charged_commission: nil,
        payment_gateway_fee: nil }
    end

  end
end
