module TransactionService::Gateway
  class PaypalAdapter < GatewayAdapter

    DataTypes = PaypalService::API::DataTypes

    def implements_process(process)
      [:none, :preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, prefer_async:)
      # Note: Quantity may be confusing in Paypal Checkout page, thus,
      # we don't use separated unit price and quantity, only the total
      # price for now.
      total = tx[:unit_price] * tx[:listing_quantity]

      create_payment_info = DataTypes.create_create_payment_request(
        {
         transaction_id: tx[:id],
         item_name: tx[:listing_title],
         item_quantity: 1,
         item_price: total,
         merchant_id: tx[:listing_author_id],
         order_total: total,
         success: gateway_fields[:success_url],
         cancel: gateway_fields[:cancel_url],
         merchant_brand_logo_url: gateway_fields[:merchant_brand_logo_url]})

      result = paypal_api.payments.request(
        tx[:community_id],
        create_payment_info,
        async: prefer_async)

      if !result[:success]
        return SyncCompletion.new(Result::Error.new(result[:error_msg]))
      end

      if prefer_async
        AsyncCompletion.new(Result::Success.new({ process_token: result[:data][:process_token] }))
      else
        AsyncCompletion.new(Result::Success.new({ redirect_url: result[:data][:redirect_url] }))
      end
    end

    def reject_payment(tx:, reason: "")
      AsyncCompletion.new(paypal_api.payments.void(tx[:community_id], tx[:id], {note: reason}))
    end

    def complete_preauthorization(tx:)
      AsyncCompletion.new(
        paypal_api.payments.get_payment(tx[:community_id], tx[:id])
        .and_then { |payment|
          paypal_api.payments.full_capture(
            tx[:community_id],
            tx[:id],
            DataTypes.create_payment_info({ payment_total: payment[:authorization_total] }))})
    end

    def get_payment_details(tx:)
      raise InterfaceMethodNotImplementedError.new
    end


    private

    def paypal_api
      PaypalService::API::Api
    end
  end

end
