module PaypalService
  module DataTypes

    module IPN
      OrderCreated = EntityUtils.define_builder(
        [:type, const_value: :order_created],
        [:order_date, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:order_id, :string, :mandatory],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, :string, :mandatory],
        [:pending_reason, :string],
        [:receipt_id, :string],
        [:order_total, :money, :mandatory]
      )

      AuthorizationCreated = EntityUtils.define_builder(
        [:type, const_value: :authorization_created],
        [:authorization_date, :mandatory, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:authorization_expires_date, :mandatory, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:order_id, :string, :mandatory],
        [:authorization_id, :string, :mandatory],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, :string, :mandatory],
        [:pending_reason, :string],
        [:receipt_id, :string],
        [:order_total, :money, :mandatory],
        [:authorization_total, :money, :mandatory]
      )

      PaymentCompleted = EntityUtils.define_builder(
        [:type, const_value: :payment_completed],
        [:payment_date, :mandatory, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:payment_id, :string, :mandatory],
        [:authorization_expires_date, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:authorization_id, :string],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, :string, :mandatory],
        [:pending_reason, const_value: :none],
        [:receipt_id, :string],
        [:authorization_total, :money],
        [:payment_total, :money, :mandatory],
        [:fee_total, :money]
      )

      PaymentRefunded = EntityUtils.define_builder(
        [:type, const_value: :payment_refunded],
        [:refunding_id, :string, :mandatory],
        [:refunded_date, :mandatory, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:payment_id, :string, :mandatory],
        [:authorization_id, :string],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, :string, :mandatory],
        [:pending_reason, const_value: :none],
        [:receipt_id, :string],
        [:authorization_total, :money],
        [:payment_total, :money, :mandatory],
        [:fee_total, :money, :mandatory]
      )

      PaymentPendingExt = EntityUtils.define_builder(
        [:type, const_value: :payment_pending_ext],
        [:pending_ext_id, :string, :mandatory],
        [:authorization_expires_date, :mandatory, str_to_time: "%H:%M:%S %b %e, %Y %Z"],
        [:authorization_id, :string, :mandatory],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:payment_status, :string, :mandatory],
        [:pending_reason, :string],
        [:receipt_id, :string],
        [:authorization_total, :money, :mandatory],
        [:payment_total, :money, :mandatory]
      )

      PaymentVoided = EntityUtils.define_builder(
        [:type, const_value: :payment_voided],
        [:authorization_id, :string],
        [:order_id, :string],
        [:payer_id, :string, :mandatory],
        [:payer_email, :string],
        [:receiver_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:payment_status, :string, :mandatory]
      )

      BillingAgreementCancelled = EntityUtils.define_builder(
        [:type, const_value: :billing_agreement_cancelled],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:billing_agreement_id, :string, :mandatory],
        [:description, :string],
        [:reason_code, :string]
      )

      PaymentDenied = EntityUtils.define_builder(
        [:type, const_value: :payment_denied],
        [:payment_status, const_value: :denied],
        [:pending_reason, const_value: :none],
        [:payer_email, :string],
        [:payer_id, :string, :mandatory],
        [:receiver_id, :string, :mandatory],
        [:receiver_email, :string, :mandatory],
        [:authorization_id, :string, :mandatory],
        [:payment_id, :string, :mandatory]
      )

      module_function

      def create_order_created(opts); OrderCreated.call(opts) end
      def create_authorization_created(opts); AuthorizationCreated.call(opts) end
      def create_payment_completed(opts); PaymentCompleted.call(opts) end
      def create_payment_refunded(opts); PaymentRefunded.call(opts) end
      def create_billing_agreement_cancelled(opts); BillingAgreementCancelled.call(opts) end
      def create_payment_pending_ext(opts); PaymentPendingExt.call(opts) end
      def create_payment_voided(opts); PaymentVoided.call(opts) end
      def create_payment_denied(opts); PaymentDenied.call(opts) end

      def from_params(params)
        p = HashUtils.symbolize_keys(params)
        type = msg_type(p[:txn_type], p[:payment_status], p[:pending_reason])

        case type
        when :order_created
          to_order_created(p)
        when :authorization_created
          to_authorization_created(p)
        when :payment_completed
          to_payment_completed(p)
        when :payment_refunded
          to_payment_refunded(p)
        when :billing_agreement_cancelled
          to_billing_agreement_cancelled(p)
        when :payment_pending_ext
          to_payment_pending_ext(p)
        when :payment_voided
          to_payment_voided(p)
        when :payment_denied
          to_payment_denied(p)
        else
          { type: type }
        end
      end

      ## Privates
      #

      def msg_type(txn_type, payment_status, pending_reason)
        txn_type = txn_type.to_s.downcase
        status, reason = payment_status.to_s.downcase, pending_reason.to_s.downcase

        if txn_type == "mp_cancel"
          return :billing_agreement_cancelled
        elsif status == "pending" && reason == "order"
          return :order_created
        elsif status == "pending" && reason == "authorization"
          return :authorization_created
        elsif status == "pending"
          return :payment_pending_ext
        elsif status == "completed"
          return :payment_completed
        elsif status == "refunded"
          return :payment_refunded
        elsif status == "voided"
          return :payment_voided
        elsif status == "denied"
          return :payment_denied
        else
          return :unknown
        end
      end
      private_class_method :msg_type

      def to_money(sum, currency)
        sum.to_money(currency)
      end
      private_class_method :to_money

      def to_order_created(params)
        p = HashUtils.rename_keys(
          {txn_id: :order_id, payment_date: :order_date},
          params)

        create_order_created(p.merge({order_total: to_money(p[:mc_gross], p[:mc_currency])}))
      end
      private_class_method :to_order_created

      def to_authorization_created(params)
        p = HashUtils.rename_keys(
          {
            txn_id: :authorization_id,
            parent_txn_id: :order_id,
            payment_date: :authorization_date,
            auth_exp: :authorization_expires_date
          },
          params)

        create_authorization_created(
          p.merge({
              order_total: to_money(p[:mc_gross], p[:mc_currency]),
              authorization_total: to_money(p[:auth_amount], p[:mc_currency])}))
      end
      private_class_method :to_authorization_created

      def to_payment_completed(params)
        p = HashUtils.rename_keys(
          {
            txn_id: :payment_id,
            auth_id: :authorization_id,
            auth_exp: :authorization_expires_date
          },
          params)

        p[:fee_total] = p[:mc_fee] ? to_money(p[:mc_fee], p[:mc_currency]) : nil
        p[:authorization_total] = p[:auth_amount] ? to_money(p[:auth_amount], p[:mc_currency]) : nil

        create_payment_completed(
          p.merge({
              payment_total: to_money(p[:mc_gross], p[:mc_currency])
          }))
      end
      private_class_method :to_payment_completed

      def to_payment_refunded(params)
        p = HashUtils.rename_keys(
          {
            txn_id: :refunding_id,
            auth_id: :authorization_id,
            parent_txn_id: :payment_id,
            payment_date: :refunded_date
          },
          params)

        with_auth_total = p[:auth_amount] ? p.merge({ authorization_total: to_money(p[:auth_amount], p[:mc_currency]) }) : p

        create_payment_refunded(
          with_auth_total.merge({
              payment_total: to_money(p[:mc_gross], p[:mc_currency]),
              fee_total: to_money(p[:mc_fee], p[:mc_currency])}))
      end
      private_class_method :to_payment_refunded


      def to_payment_pending_ext(params)
        p = HashUtils.rename_keys(
          {
            txn_id: :pending_ext_id,
            auth_id: :authorization_id,
            auth_exp: :authorization_expires_date,
          },
          params
        )

        create_payment_pending_ext(
          p.merge({
              payment_total: to_money(p[:mc_gross], p[:mc_currency]),
              authorization_total: to_money(p[:auth_amount], p[:mc_currency]) }))
      end
      private_class_method :to_payment_pending_ext

      def to_payment_voided(params)
        p = HashUtils.rename_keys(
          {
            auth_id: :authorization_id,
            parent_txn_id: :order_id
          },
          params
        )

        create_payment_voided(p)
      end
      private_class_method :to_payment_voided

      def to_billing_agreement_cancelled(params)
        p = HashUtils.rename_keys(
          {
            mp_id: :billing_agreement_id,
            mp_desc: :description
          },
          params
        )

        create_billing_agreement_cancelled(p)
      end
      private_class_method :to_billing_agreement_cancelled

      def to_payment_denied(params)
        p = HashUtils.rename_keys(
          {
            auth_id: :authorization_id,
            parent_txn_id: :payment_id
          },
          params
        )

        create_payment_denied(p)
      end
      private_class_method :to_payment_denied

    end
  end
end
