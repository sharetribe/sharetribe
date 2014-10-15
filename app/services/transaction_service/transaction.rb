module TransactionService
  module Transaction
    module Command
      module_function

      def create
        raise "Not implemented"
      end

      def preauthorize
        raise "Not implemented"
      end

      def reject
        raise "Not implemented"
      end

      def complete_preauthorization(transaction_id)
        transaction = MarketplaceService::Transaction::Query.transaction(transaction_id)
        payment_type = MarketplaceService::Community::Query.payment_type(transaction[:community_id])

        case payment_type
        when :braintree
          BraintreeService::Payments::Command.submit_to_settlement(transaction[:id], transaction[:community_id])
          MarketplaceService::Transaction::Command.transition_to(transaction[:id], :paid)
        when :paypal
          paypal_account = PaypalService::PaypalAccount::Query.personal_account(transaction[:listing][:author_id], transaction[:community_id])
          paypal_payment = PaypalService::PaypalPayment::Query.for_transaction(transaction[:id])

          api_params = {
            receiver_username: paypal_account[:email],
            authorization_id: paypal_payment[:authorization_id],
            payment_total: paypal_payment[:authorization_total]
          }

          merchant = PaypalService::MerchantInjector.build_paypal_merchant
          capture_request = PaypalService::DataTypes::Merchant.create_do_full_capture(api_params)
          capture_response = merchant.do_request(capture_request)

          if capture_response[:success]
            PaypalService::PaypalPayment::Command.update(paypal_payment.merge(capture_response))

            if capture_response[:payment_status] != "completed"
              transaction = MarketplaceService::Transaction::Command.transition_to(transaction[:id], :pending_ext)
              DataTypes::Transaction.create_complete_preauthorization_response({
                  transaction: transaction,
                  gateway_fields: { pending_reason: capture_response[:pending_reason] }})

            else
              transaction = MarketplaceService::Transaction::Command.transition_to(transaction[:id], :paid)
              DataTypes::Transaction.create_complete_preauthorization_response({
                  transaction: transaction
                  })
            end
          else
            # TODO Use Paypal logger
          end
        end
      end

      def invoice
        raise "Not implemented"
      end

      def pay_invoice
        raise "Not implemented"
      end

      def complete
        raise "Not implemented"
      end

      def cancel
        raise "Not implemented"
      end
    end
  end
end
