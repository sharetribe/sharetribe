module PaypalService
  class IPN

    Invnum = PaypalService::API::Invnum

    def initialize(events)
      @events = events
    end

    PAYMENT_ROW_UPDATE_TYPES = [
      :order_created,
      :payment_review,
      :authorization_created,
      :authorization_expired,
      :payment_completed,
      :payment_pending_ext,
      :payment_voided,
      :payment_denied,
      :commission_paid,
      :commission_denied,
      :commission_pending_ext,
      :payment_adjustment
    ]

    def handle_msg(ipn_msg)
      case(ipn_msg[:type])
      when *PAYMENT_ROW_UPDATE_TYPES
        payment = handle_payment_update(ipn_msg)
        @events.send(:payment_updated, :success, payment) unless payment.nil?
      when :billing_agreement_created
        # This ipn message contains only payer_id and billing_agreement_id
        #
        # There are two scenarios when we receive this message:
        # 1. Pending billing agreement - a client has failed to return and we don't have a billing_agreement_id
        # 2. Confirmed billing agreement - we have already all the information
        #
        # From the ipn message, we don't have enough information to infer the correct agreement.
        # Therefore, ack that we have id'd the message and do nothing in order to avoid hard to debug bugs in bordreline cases.
        # Failing to correctly confirm a pending agreement just enforces the user to try again.
        true
      when :billing_agreement_cancelled
        PaypalService::Store::PaypalAccount.delete_billing_agreement_by_payer_and_agreement_id(
          payer_id: ipn_msg[:payer_id],
          billing_agreement_id: ipn_msg[:billing_agreement_id]
        )
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
      PaypalService::Store::PaypalPayment.update(opts.merge(data: ipn_msg))
    end

    def identity_opts(ipn_msg)
      if [:commission_paid, :commission_pending_ext, :commission_denied].include?(ipn_msg[:type])
        { community_id: Invnum.community_id(ipn_msg[:invnum]), transaction_id: Invnum.transaction_id(ipn_msg[:invnum]) }
      else
        { authorization_id: ipn_msg[:authorization_id], order_id: ipn_msg[:order_id] }
      end
    end
  end
end
