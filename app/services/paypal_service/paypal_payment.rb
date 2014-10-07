module PaypalService
  module PaypalPayment

    PaypalPaymentModel = ::PaypalPayment

    module Entity
      module_function

      PaymentUpdate = EntityUtils.define_builder(
        [:payer_id, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, one_of: [:pending, :completed, :refunded]]) # Might have to handle :initiated / nil?

      OPT_UPDATE_FIELDS = [
        :order_id,
        :authorization_id,
        :authorization_date,
        :authorization_total_cents,
        :payment_id,
        :payment_date,
        :payment_total_cents,
        :fee_total_cents,
        :pending_reason
      ]

      def valid?(payment_update)
        payment_update[:order_id] || payment_update[:authorization_id]
      end

      def from_order(order)
        cent_totals = [:authorization_total, :fee_total, :payment_total]
          .reduce({}) do |cent_totals, m_key|
            m = order[m_key]
            cent_totals["#{m_key}_cents".to_sym] = m.cents unless m.nil?
            cent_totals
          end

        payment_update = PaymentUpdate.call(order.merge({payment_status: order[:payment_status].downcase.to_sym}))
        payment_update = payment_update.merge(HashUtils.sub(order, *OPT_UPDATE_FIELDS)).merge(cent_totals)
        raise ArgumentError.new("Must have either order_id or authorization_id") unless valid?(payment_update)

        return payment_update
      end
    end

    module Command
      module_function

      def update_from_order(order)
        payment_entity = Entity.from_order(order)

        payment = find_payment(payment_entity)
        if payment.nil?
          raise ArgumentError.new("Order doesn't match an existing payment.")
          # Or just log a warning if we have a valid path to order update before initial recording?
        end

        payment.update_attributes!(payment_entity)

        Result::Success.new # TODO Should return a hash of the updated account instead
      end


      ## Privates

      def find_payment(payment_entity)
        if (payment_entity[:order_id])
          payment = PaypalPaymentModel.where(order_id: payment_entity[:order_id]).first
        else
          payment = PaypalPaymentModel.where(authorization_id: payment_entity[:authorization_id]).first
        end

        if (payment && payment_entity[:receiver_id] == payment.receiver_id && payment_entity[:payer_id] == payment.payer_id)
          return payment
        end

        return nil
      end
    end
  end
end
