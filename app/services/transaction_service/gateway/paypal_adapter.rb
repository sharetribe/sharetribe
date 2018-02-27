module TransactionService::Gateway
  class PaypalAdapter < GatewayAdapter

    DataTypes = PaypalService::API::DataTypes

    def implements_process(process)
      [:none, :preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, force_sync:)
      create_payment_info = DataTypes.create_create_payment_request(
        {
         transaction_id: tx.id,
         payment_action: :authorization,
         item_name: tx.listing_title,
         item_quantity: tx.listing_quantity,
         item_price: tx.unit_price,
         merchant_id: tx.listing_author_id,
         require_shipping_address: tx.delivery_method == 'shipping',
         shipping_total: tx.shipping_price,
         order_total: order_total(tx),
         success: gateway_fields[:success_url],
         cancel: gateway_fields[:cancel_url],
         merchant_brand_logo_url: gateway_fields[:merchant_brand_logo_url]})

      result = paypal_api.payments.request(
        tx.community_id,
        create_payment_info,
        force_sync: force_sync)

      unless result[:success]
        return SyncCompletion.new(result)
      end

      if result[:data][:process_token].present?
        # PayPal API performed the operation asynchronously
        AsyncCompletion.new(Result::Success.new({ process_token: result[:data][:process_token] }))
      else
        # PayPal API performed the operation synchronously
        AsyncCompletion.new(Result::Success.new({ redirect_url: result[:data][:redirect_url] }))
      end
    end

    def reject_payment(tx:, reason: "")
      AsyncCompletion.new(paypal_api.payments.void(tx.community_id, tx.id, {note: reason}))
    end

    def complete_preauthorization(tx:)
      AsyncCompletion.new(
        paypal_api.payments.get_payment(tx.community_id, tx.id)
        .and_then { |payment|
          paypal_api.payments.full_capture(
            tx.community_id,
            tx.id,
            DataTypes.create_payment_info({ payment_total: payment[:authorization_total] }))
        })
    end

    def get_payment_details(tx:)
      payment = paypal_api.payments.get_payment(tx.community_id, tx.id).maybe

      payment_total = payment[:payment_total].or_else(nil)
      total_price = Maybe(payment[:payment_total].or_else(payment[:authorization_total].or_else(nil)))
                    .or_else(order_total(tx))

      { payment_total: payment_total,
        total_price: total_price,
        charged_commission: payment[:commission_total].or_else(nil),
        payment_gateway_fee: payment[:fee_total].or_else(nil) }
    end

    private

    def paypal_api
      PaypalService::API::Api
    end

    def order_total(tx)
      # Note: Quantity may be confusing in Paypal Checkout page, thus,
      # we don't use separated unit price and quantity, only the total
      # price for now.

      shipping_total = Maybe(tx.shipping_price).or_else(0)
      tx.unit_price * tx.listing_quantity + shipping_total
    end
  end

end
