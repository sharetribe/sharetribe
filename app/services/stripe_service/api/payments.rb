module StripeService::API
  class Payments
    class << self
      PaymentStore = StripeService::Store::StripePayment

      TransactionStore = TransactionService::Store::Transaction

      def create_preauth_payment(tx, gateway_fields)
        seller_account = accounts_api.get(community_id: tx.community_id, person_id: tx.listing_author_id).data
        if !seller_account || !seller_account[:stripe_seller_id].present?
          return Result::Error.new("No Seller Account")
        end

        if gateway_fields[:stripe_payment_method_id].present?
          wrap_in_report(tx: tx, start: :create_intent_start, success: :create_intent_success, failed: :create_intent_failed) do
            do_create_preauth_payment(tx, gateway_fields, seller_account)
          end
        else
          Result::Error.new("No payment method present")
        end
      end

      def cancel_preauth(tx, reason)
        payment = PaymentStore.get(tx.community_id, tx.id)
        wrap_in_report(tx: tx, start: :cancel_intent_start, success: :cancel_intent_success, failed: :cancel_intent_failed) do
          do_cancel_preauth(tx, reason)
        end
      end

      def capture(tx)
        payment = PaymentStore.get(tx.community_id, tx.id)
        wrap_in_report(tx: tx, start: :capture_intent_start, success: :capture_intent_success, failed: :capture_intent_failed) do
          do_capture(tx)
        end
      end

      def payment_details(tx)
        payment = PaymentStore.get(tx.community_id, tx.id)
        unless payment
          total      = order_total(tx)
          commission = tx.commission
          buyer_commission = tx.buyer_commission
          fee        = Money.new(0, total.currency)
          payment = {
            sum: total,
            commission: commission,
            real_fee: fee,
            subtotal: total - fee,
            buyer_commission: buyer_commission
          }
        end

        # in case of :destination payments, gateway fee is always charged from admin account, we cannot know it upfront, as transfer to seller = total - commission, is immediate
        # in case of :separate payments, gateway fee is charged from admin account, but then deducted from seller on delayed transfer
        gateway_fee = if stripe_api.charges_mode(tx.community_id) == :destination
            Money.new(0, payment[:sum].currency)
          else
            payment[:real_fee]
          end
        {
          payment_total: payment[:sum],
          total_price: payment[:subtotal],
          charged_commission: payment[:commission],
          payment_gateway_fee: gateway_fee,
          buyer_commission: payment[:buyer_commission] || 0
        }
      end

      def payout(tx)
        wrap_in_report(tx: tx, start: :create_payout_start, success: :create_payout_success, failed: :create_payout_failed) do
          seller_account = accounts_api.get(community_id: tx.community_id, person_id: tx.listing_author_id).data
          payment = PaymentStore.get(tx.community_id, tx.id)

          seller_gets = payment[:subtotal] - payment[:commission]

          case stripe_api.charges_mode(tx.community_id)
          when :separate
            seller_gets -= payment[:real_fee] || 0
            if seller_gets > 0
              result = stripe_api.perform_transfer(
                community: tx.community_id,
                account_id: seller_account[:stripe_seller_id],
                amount_cents: seller_gets.cents,
                amount_currency: payment[:sum].currency,
                initial_amount: payment[:subtotal].cents,
                charge_id: payment[:stripe_charge_id],
                metadata: {sharetribe_transaction_id: tx.id}
              )
            end
          when :destination
            if seller_gets > 0
              charge = stripe_api.get_charge(community: tx.community_id, charge_id: payment[:stripe_charge_id])
              transfer = stripe_api.get_transfer(community: tx.community_id, transfer_id: charge.transfer)
              result = stripe_api.perform_payout(
                community: tx.community_id,
                account_id: seller_account[:stripe_seller_id],
                amount_cents: transfer.amount,
                currency: transfer.currency,
                metadata: {shretribe_order_id: tx.id}
              )
            end
          end

          payment = PaymentStore.update(transaction_id: tx.id, community_id: tx.community_id,
                                        data: {
                                          status: 'transfered',
                                          stripe_transfer_id: seller_gets > 0 ? result.id : "ZERO",
                                          transfered_at: Time.zone.now
                                        })

          payment
        end
      end

      def stripe_api
        StripeService::API::Api.wrapper
      end

      def accounts_api
        StripeService::API::Api.accounts
      end

      def order_total(tx)
        shipping_total = Maybe(tx.shipping_price).or_else(0)
        tx.unit_price * tx.listing_quantity + shipping_total + tx.buyer_commission
      end

      private

      def wrap_in_report(tx:, start:, success:, failed:)
        report = StripeService::Report.new(tx: tx)
        report.send(start)
        result = yield
        report.send(success)
        result
      rescue StandardError => exception
        params_to_airbrake = StripeService::Report.new(tx: tx, exception: exception).send(failed)
        if params_to_airbrake
          exception.extend ParamsToAirbrake
          exception.params_to_airbrake = {stripe: params_to_airbrake}
        end
        Airbrake.notify(exception)
        Result::Error.new(exception.message, exception)
      end

      def do_create_preauth_payment(tx, gateway_fields, seller_account)
        seller_id  = seller_account[:stripe_seller_id]
        payment_method_id = gateway_fields[:stripe_payment_method_id]

        subtotal   = order_total(tx)
        total      = subtotal
        commission = tx.commission
        buyer_commission = tx.buyer_commission
        fee        = Money.new(0, subtotal.currency)

        description = "Payment #{tx.id} for #{tx.listing_title} via #{gateway_fields[:service_name]} "
        metadata = {
          sharetribe_transaction_id: tx.id,
          sharetribe_seller_id: tx.listing_author_id,
          sharetribe_payer_id: tx.starter_id,
          sharetribe_mode: stripe_api.charges_mode(tx.community_id)
        }

        if payment_method_id.present?
          intent = stripe_api.create_payment_intent(
            community: tx.community_id,
            seller_account_id: seller_id,
            payment_method_id: payment_method_id,
            amount: total.cents,
            currency: total.currency.iso_code,
            fee: commission.cents + buyer_commission.cents,
            description: description,
            metadata: metadata)
        else
          return Result::Error.new("No payment method present")
        end

        payment_data = {
          payer_id: tx.starter_id,
          receiver_id: tx.listing_author_id,
          currency: tx.unit_price.currency.iso_code,
          sum_cents: total.cents,
          commission_cents: commission.cents,
          buyer_commission_cents: buyer_commission.cents,
          fee_cents: fee.cents,
          subtotal_cents: subtotal.cents
        }
        if intent
          payment_data[:stripe_payment_intent_id] = intent.id
          if intent.status == 'requires_action' &&
             intent.next_action.type == 'use_stripe_sdk'
            payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_REQUIRES_ACTION
            payment_data[:stripe_payment_intent_client_secret] = intent.client_secret
          elsif intent.status == 'requires_capture'
            stripe_charge = intent['charges']['data'].first
            payment_data[:stripe_charge_id] = stripe_charge.id
            payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_REQUIRES_CAPTURE
          elsif intent.status == 'succeeded'
            payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_SUCCESS
          else
            payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_INVALID
          end
        end
        payment = PaymentStore.create(tx.community_id, tx.id, payment_data)

        if gateway_fields[:shipping_address].present?
          TransactionStore.upsert_shipping_address(
            community_id: tx.community_id,
            transaction_id: tx.id,
            addr: gateway_fields[:shipping_address])
        end
        Result::Success.new(payment)
      end

      def do_cancel_preauth(tx, reason)
        payment = PaymentStore.get(tx.community_id, tx.id)
        payment_data = {status: 'canceled'}
        if payment[:stripe_payment_intent_id].present?
          stripe_api.cancel_payment_intent(community: tx.community,
                                           payment_intent_id: payment[:stripe_payment_intent_id])
          payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_CANCELED
        else
          return Result::Error.new("Cannot cancel preauth: no intent in payment data")
        end
        payment = PaymentStore.update(transaction_id: tx.id, community_id: tx.community_id, data: payment_data)
        Result::Success.new(payment)
      end

      def do_capture(tx)
        payment = PaymentStore.get(tx.community_id, tx.id)
        seller_account = accounts_api.get(community_id: tx.community_id, person_id: tx.listing_author_id).data
        payment_data = {status: 'paid'}
        if payment[:stripe_payment_intent_id].present?
          intent = stripe_api.capture_payment_intent(community: tx.community,
                                                     payment_intent_id: payment[:stripe_payment_intent_id])
          charge = intent['charges']['data'].first
          payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_SUCCESS
        else
          return Result::Error.new("Cannot capture: no intent in payment data")
        end
        balance_txn = stripe_api.get_balance_txn(community: tx.community_id, balance_txn_id: charge.balance_transaction, account_id: seller_account[:stripe_seller_id])
        payment = PaymentStore.update(transaction_id: tx.id, community_id: tx.community_id,
                                      data: payment_data.merge!({
                                        real_fee_cents: balance_txn.fee,
                                        available_on: Time.zone.at(balance_txn.available_on)
                                      }))
        Result::Success.new(payment)
      end
    end
  end
end
