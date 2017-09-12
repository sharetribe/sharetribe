module TransactionService::Gateway

  class FreeAdapter < GatewayAdapter

    def implements_process(process)
      [:none].include?(process)
    end

    def get_payment_details(tx:)
      { payment_total: nil,
        total_price: tx.unit_price ? tx.unit_price * tx.listing_quantity : nil,
        charged_commission: nil,
        payment_gateway_fee: nil }
    end

  end
end
