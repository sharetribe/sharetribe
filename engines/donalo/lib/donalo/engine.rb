module Donalo
  class Engine < ::Rails::Engine
    isolate_namespace Donalo

    # centralized payments
    initializer "donalo/monkey_patch/centralized_payments" do |app|
      # referencing monkey patched modules to ensure they are loaded
      PATCHED_OBJECTS = [
        ::StripeHelper,
        ::TransactionService::Transaction,
        ::StripeService::API::StripeApiWrapper,
        ::StripeService::API::Payments,
        ::StripeService::Report
      ]

      # StripeHelper.user_active_true? to always return true, so the
      # users don't need to setup their payment setings
      module ::StripeHelper
        class << self
          def user_stripe_active?(community_id, person_id)
            return true
          end
        end
      end

      module ::TransactionService::Transaction
        class << self
          def can_start_transaction(opts)
            ::Result::Success.new(result: true)
          end
        end
      end

      class ::StripeService::API::StripeApiWrapper
        class << self
          # TODO maybe do the same in "charge" method?
          # removing destination fields, and on_behalf fields here, so payment is done to the platform, rather than p2p
          def create_payment_intent(community:, seller_account_id:, payment_method_id:, amount:, currency:, fee:, description:, metadata:)
            with_stripe_payment_config(community) do |payment_settings|
              Stripe::PaymentIntent.create(
                capture_method: 'manual',
                payment_method: payment_method_id,
                amount: amount,
                currency: currency,
                confirmation_method: 'manual',
                confirm: true,
                description: description,
                metadata: metadata
              )
            end
          end

        end
      end

      class ::StripeService::API::Payments
        class << self
          def create_preauth_payment(tx, gateway_fields)
            seller_account = {}

            if gateway_fields[:stripe_payment_method_id].present?
              wrap_in_report(tx: tx, start: :create_intent_start, success: :create_intent_success, failed: :create_intent_failed) do
                do_create_preauth_payment(tx, gateway_fields, seller_account)
              end
            elsif gateway_fields[:stripe_token].present?
              wrap_in_report(tx: tx, start: :create_charge_start, success: :create_charge_success, failed: :create_charge_failed) do
                do_create_preauth_payment(tx, gateway_fields, seller_account)
              end
            else
              Result::Error.new("No payment method or token present")
            end
          end

          def do_capture(tx)
            payment = PaymentStore.get(tx.community_id, tx.id)
            # TODO maybe we should mock the method that gets seller account instead
            seller_account = {}
            payment_data = {status: 'paid'}
            if payment[:stripe_payment_intent_id].present?
              intent = stripe_api.capture_payment_intent(community: tx.community,
                                                         payment_intent_id: payment[:stripe_payment_intent_id])
              charge = intent['charges']['data'].first
              payment_data[:stripe_payment_intent_status] = StripePayment::PAYMENT_INTENT_SUCCESS
            elsif payment[:stripe_charge_id].present?
              charge = stripe_api.capture_charge(community: tx.community_id, charge_id: payment[:stripe_charge_id], seller_id: seller_account[:stripe_seller_id])
            else
              return Result::Error.new("Cannot capture: no intent or charge in payment data")
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

      class ::StripeService::Report
        MockStripeAccount = Struct.new(:stripe_seller_id)

        def stripe_account
          @stripe_account ||= MockStripeAccount.new
        end
      end

      app.config.assets.precompile += %w(donalo/styles.css donalo/styles-non-admin.css)
    end

    # stock control
    initializer "donalo/monkey_patch/stock_control" do |app|
      Donalo.app_root = app.root

      PATCHED_OBJECTS = [
        ::Listing,
        ::ListingsController,
        ::TransactionService::Transaction,
      ]

      class ::ListingsController
        alias_method :original_show, :show

        def show
          original_show
          render 'listings/wrapped_show'
        end
      end

      class ::Listing
        def available_units
          return 1 unless stock

          stock.numeric_value.to_i
        end

        def minimum_required_units
          return 1 unless minimum_required_units_field

          answer_for(minimum_required_units_field).numeric_value.to_i
        end

        def stock
          return nil unless stock_custom_field

          answer_for(stock_custom_field)
        end

        private

        def stock_custom_field
          @stock_custom_field ||= CustomFieldName.find_by(locale: 'es', value: 'Cantidad disponible')&.custom_field
        end

        def minimum_required_units_field
          @minimum_required_units_field ||= CustomFieldName.find_by(locale: 'es', value: 'Cantidad mínima a solicitar')&.custom_field
        end
      end

      module ::TransactionService::Transaction
        class << self
          alias_method :original_reject, :reject
          alias_method :original_create, :create
          alias_method :original_complete_preauthorization, :complete_preauthorization

          def create(opts, force_sync: true)
            result = original_create(
              opts,
              force_sync: force_sync
            )

            return result unless result.success

            transaction_id = result.data[:transaction].id

            Donalo::StockUpdater.new(
              transaction_id: transaction_id,
              rollback: false
            ).update

            result
          end

          def reject(community_id:, transaction_id:, message: nil, sender_id: nil)
            result = original_reject(
              community_id: community_id,
              transaction_id: transaction_id,
              message: message,
              sender_id: sender_id
            )

            Donalo::StockUpdater.new(
              transaction_id: transaction_id,
              rollback: true
            ).update

            result
          end

          def complete_preauthorization(community_id:, transaction_id:, message: nil, sender_id: nil)
            Donalo::AvailabilityUpdater.new(
              transaction_id: transaction_id
            ).update

            original_complete_preauthorization(
              community_id: community_id,
              transaction_id: transaction_id,
              message: message,
              sender_id: sender_id
            )
          end
        end
      end
    end
  end
end
