module PaypalService
  class IPN

    extend PaypalService::IPNInjector

    def initialize(events)
      @events = events
    end

    ORDER_UPDATE_TYPES = [:order_created, :authorization_created, :payment_completed, :payment_pending_ext, :payment_voided]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *ORDER_UPDATE_TYPES
        PaypalService::Store::PaypalPayment.ipn_update(ipn_msg)
        @events.send(:payment_voided, :success, ipn_msg) if (ipn_msg[:type] == :payment_voided)
      when :billing_agreement_cancelled
        PaypalService::PaypalAccount::Command.delete_cancelled_billing_agreement(ipn_msg[:payer_id], ipn_msg[:billing_agreement_id])
      when :payment_refunded
        PaypalService::Store::PaypalRefund.create(ipn_msg)
      else
        #partial refund?
        raise NoMethodError
      end
    end
  end
end
