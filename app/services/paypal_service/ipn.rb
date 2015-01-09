module PaypalService
  class IPN

    Invnum = PaypalService::API::Invnum

    def initialize(events)
      @events = events
    end

    PAYMENT_ROW_UPDATE_TYPES = [
      :order_created,
      :authorization_created,
      :payment_completed,
      :payment_pending_ext,
      :payment_voided,
      :payment_denied,
      :commission_paid
    ]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *PAYMENT_ROW_UPDATE_TYPES
        payment = handle_payment_update(ipn_msg)
        @events.send(:payment_updated, :success, payment) unless payment
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

    def handle_payment_update(ipn_msg)
      opts = identity_opts(ipn_msg)
      PaypalService::Store::PaypalPayment.update_tmp(ipn_msg, opts)
    end

    def identity_opts(ipn_msg)
      if ipn_msg[:type] == :commission_paid
        { community_id: Invnum.community_id(ipn_msg[:invnum]), transaction_id: Invnum.transaction_id(ipn_msg[:invnum]) }
      else
        { authorization_id: ipn_msg[:authorization_id], order_id: ipn_msg[:order_id] }
      end
    end
  end
end
