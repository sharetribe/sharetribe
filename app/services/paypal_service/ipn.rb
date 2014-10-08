module PaypalService
  module IPN

    module_function

    ORDER_UPDATE_TYPES = [:order_created, :authorization_created, :payment_completed]

    def handle_msg(ipn_msg)
      if (ORDER_UPDATE_TYPES.include?(ipn_msg[:type]))
        PaypalService::PaypalPayment::Command.update(ipn_msg)
      else
        # billing agreement cancelled, payment refunded
        raise NoMethodError
      end
    end
  end
end
