module PaypalService
  module IPN

    module_function

    ORDER_UPDATE_TYPES = [:order_created, :authorization_created, :payment_completed]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *ORDER_UPDATE_TYPES
        PaypalService::PaypalPayment::Command.update(ipn_msg)
      when :billing_agreement_cancelled
        PaypalService::PaypalAccount::Command.delete_cancelled_billing_agreement(ipn_msg[:payer_id], ipn_msg[:billing_agreement_id])
      else
        #payment refunded
        raise NoMethodError
      end
    end
  end
end
