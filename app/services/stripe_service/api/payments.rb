module StripeService::API
  class Payments
    class << self
      PaymentStore = StripeService::Store::StripePayment

      def create_preauth_payment(tx, gateway_fields)
        seller_account = accounts_api.get(community_id: tx[:community_id], person_id: tx[:listing_author_id]).data
        if !seller_account || !seller_account[:stripe_seller_id].present?
          return SyncCompletion.new(Result::Error.new("No Seller Account"))
        end

        payer_account = create_or_update_payer(tx[:community_id], tx[:starter_id], gateway_fields)

        customer_id   = payer_account[:stripe_customer_id]
        seller_id     = seller_account[:stripe_seller_id]

        case stripe_api.destination(tx[:community_id])
        when :platform
          source_id  = payer_account[:stripe_customer_id]
          target_country = stripe_api.platform_country(tx[:community_id])
        when :seller
          source_id  = stripe_api.create_token(tx[:community_id], customer_id, seller_id).id
          target_country = seller_account[:address_country]
        end

        subtotal   = order_initial_total(tx)
        total      = order_total(tx, payer_account[:stripe_source_country], target_country)
        commission = order_commission(tx)
        fee        = order_fee(tx, payer_account[:stripe_source_country], target_country)

        stripe_charge = stripe_api.charge(tx[:community_id], source_id, seller_id, total.cents, commission.cents, total.currency.iso_code, "PURCHASE #{tx[:id]}")

        payment = PaymentStore.create(tx[:community_id], tx[:id], {
          payer_id: tx[:starter_id],
          receiver_id: tx[:listing_author_id],
          currency: tx[:unit_price].currency.iso_code,
          sum_cents: total.cents,
          commission_cents: commission.cents,
          fee_cents: fee.cents,
          subtotal_cents: subtotal.cents,
          stripe_charge_id: stripe_charge.id
        })

        Result::Success.new(payment)
      rescue => e
        Result::Error.new(e.message)
      end

      def cancel_preauth(tx, reason)
        payment = PaymentStore.get(tx[:community_id], tx[:id])
        seller_account = accounts_api.get(community_id: tx[:community_id], person_id: tx[:listing_author_id]).data
        stripe_api.cancel_charge(tx[:community_id], payment[:stripe_charge_id], seller_account[:stripe_seller_id], reason)
        payment = PaymentStore.update(transaction_id: tx[:id], community_id: tx[:community_id], data: {status: 'canceled'})
        Result::Success.new(payment)
      rescue => e
        Result::Error.new(e.message)
      end

      def capture(tx)
        payment = PaymentStore.get(tx[:community_id], tx[:id])
        seller_account = accounts_api.get(community_id: tx[:community_id], person_id: tx[:listing_author_id]).data
        charge = stripe_api.capture_charge(tx[:community_id], payment[:stripe_charge_id], seller_account[:stripe_seller_id])
        balance_txn = stripe_api.get_balance_txn(tx[:community_id], charge.balance_transaction, seller_account[:stripe_seller_id])
        payment = PaymentStore.update(transaction_id: tx[:id], community_id: tx[:community_id],
                                      data: {
                                        status: 'paid',
                                        real_fee_cents: balance_txn.fee,
                                        available_on: Time.at(balance_txn.available_on)
                                      })
        Result::Success.new(payment)
      rescue => e
        Result::Error.new(e.message)
      end

      def payment_details(tx)
        payment = PaymentStore.get(tx[:community_id], tx[:transaction_id] || tx[:id])
        unless payment
          target_country = stripe_api.platform_country(tx[:community_id])

          total      = order_total(tx, target_country, target_country)
          commission = order_commission(tx)
          fee        = order_fee(tx, target_country, target_country)
          payment = {
            sum: total,
            commission: commission,
            fee: fee,
            subtotal: total - fee,
          }
        end
        {
          payment_total:       payment[:sum],
          total_price:         payment[:subtotal],
          charged_commission:  payment[:commission],
          payment_gateway_fee: payment[:real_fee] || payment[:fee]
        }
      end

      def payout(tx)
        seller_account = accounts_api.get(community_id: tx[:community_id], person_id: tx[:listing_author_id]).data
        payment = PaymentStore.get(tx[:community_id], tx[:id])

        seller_gets = payment[:subtotal] - payment[:commission]

        case stripe_api.destination(tx[:community_id])
        when :platform
          # we decrease seller payment by stripe fee unless we included it on top of total price for customer
          if stripe_api.fee_mode(tx[:community_id]) == :put_on_seller
            seller_gets -= payment[:real_fee] || 0
          end
          if seller_gets > 0
            result = stripe_api.perform_transfer(tx[:community_id], seller_account[:stripe_seller_id], seller_gets.cents, payment[:sum].currency, payment[:stripe_charge_id])
          end
        when :seller
          # charge was direct to seller so stripe fee was already included
          # FIXME-SS payout schedule - do this only for manual payout
          if seller_gets > 0
            result = stripe_api.perform_payout(tx[:community_id], seller_account[:stripe_seller_id], seller_gets.cents, payment[:sum].currency)
          end
        end

        payment = PaymentStore.update(transaction_id: tx[:id], community_id: tx[:community_id],
                                      data: {
                                        status: 'transfered',
                                        stripe_transfer_id: seller_gets > 0 ? result.id : "ZERO",
                                        transfered_at: Time.now
                                      })
        Result::Success.new(payment)
      rescue => e
        Result::Error.new(e.message)
      end

      def stripe_api
        StripeService::API::Api.wrapper
      end

      def accounts_api
        StripeService::API::Api.accounts
      end

      def create_or_update_payer(community_id, person_id, gateway_fields)
        payer_account     = accounts_api.get(community_id: community_id, person_id: person_id).data
        if gateway_fields[:stripe_token].present?
          unless payer_account
            payer_account = accounts_api.create_customer(community_id: community_id, person_id: person_id, body: {}).data
          end

          if payer_account[:stripe_customer_id].present?
            stripe_customer = stripe_api.update_customer(community_id, payer_account[:stripe_customer_id], gateway_fields[:stripe_token])
          else
            stripe_customer = stripe_api.register_customer(community_id, gateway_fields[:stripe_email], gateway_fields[:stripe_token])
            accounts_api.update_field(community_id: community_id, person_id: person_id, field: :stripe_customer_id, value: stripe_customer.id)
          end
          card_info, card_country = stripe_api.get_card_info(stripe_customer)
          payer_account = accounts_api.update_field(community_id: community_id, person_id: person_id, field: :stripe_source_info, value: card_info).data
          payer_account = accounts_api.update_field(community_id: community_id, person_id: person_id, field: :stripe_source_country, value: card_country).data
        end
        payer_account
      end

      def order_initial_total(tx)
        shipping_total = Maybe(tx[:shipping_price]).or_else(0)
        tx[:unit_price] * tx[:listing_quantity] + shipping_total
      end

      # Calculate Stripe fee for charge and add to initial
      def order_total(tx, customer_country, seller_country)
        goal_total = order_initial_total(tx)

        case stripe_api.fee_mode(tx[:community_id])
        when :put_on_buyer
          StripeService::API::FeeCalculator.total_with_fee(goal_total, seller_country, customer_country)
        when :put_on_seller
          goal_total
        end
      end

      def order_commission(tx)
        TransactionService::Transaction.calculate_commission(tx[:unit_price] * tx[:listing_quantity], tx[:commission_from_seller], tx[:minimum_commission])
      end

      def order_fee(tx, customer_country, seller_country)
        order_total(tx, customer_country, seller_country) - order_initial_total(tx)
      end
    end
  end
end
