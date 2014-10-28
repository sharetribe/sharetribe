module PaypalService
  module IPN

    module_function

    ORDER_UPDATE_TYPES = [:order_created, :authorization_created, :payment_completed, :payment_pending_ext]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *ORDER_UPDATE_TYPES
        PaypalService::Store::PaypalPayment.ipn_update(ipn_msg)
      when :billing_agreement_cancelled
        PaypalService::PaypalAccount::Command.delete_cancelled_billing_agreement(ipn_msg[:payer_id], ipn_msg[:billing_agreement_id])
      when :payment_refunded
        PaypalService::PaypalRefund::Command.create(ipn_msg)
      else
        #partial refund?, pending?
        raise NoMethodError
      end
    end
  end
end
