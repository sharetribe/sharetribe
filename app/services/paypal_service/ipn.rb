module PaypalService
  class IPN

    def initialize(events)
      @events = events
    end

    ORDER_UPDATE_TYPES = [:order_created, :authorization_created, :payment_completed, :payment_pending_ext, :payment_voided, :payment_denied]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *ORDER_UPDATE_TYPES
        payment = PaypalService::Store::PaypalPayment.ipn_update(ipn_msg)
        @events.send(:payment_updated, :success, payment) unless payment.nil?
      when :billing_agreement_cancelled
        PaypalService::PaypalAccount::Command.delete_cancelled_billing_agreement(ipn_msg[:payer_id], ipn_msg[:billing_agreement_id])
      when :payment_refunded
        PaypalService::Store::PaypalRefund.create(ipn_msg)
      else
        #partial refund?
        raise NoMethodError
      end
    end

    def store_and_create_handler(params)
      # PayPal api sends us ipn messages with charset dependent on sellers settings that we cannot control
      converted = HashUtils.map_values(params) { |val| val.force_encoding(params[:charset]).encode("utf-8", invalid: :replace, replace: "") }

      msg = PaypalIpnMessage.create(body: converted)
      Delayed::Job.enqueue(HandlePaypalIpnMessageJob.new(msg.id))
    end
  end
end
