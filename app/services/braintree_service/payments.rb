module BraintreeService
  module Payments
    module Command
      module_function

      def submit_to_settlement(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)

        braintree_transaction_id = transaction.payment.braintree_transaction_id

        result = BraintreeApi.submit_to_settlement(transaction.community, braintree_transaction_id)

        if result
          BTLog.info("Submitted authorized payment #{transaction_id} to settlement")
        else
          BTLog.error("Could not submit authorized payment #{transaction_id} to settlement")
        end
      end

      def void_transaction(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)

        braintree_transaction_id = transaction.payment.braintree_transaction_id

        result = BraintreeApi.void_transaction(community, braintree_transaction_id)

        if result
          BTLog.info("Voided transaction #{transaction_id}")
        else
          BTLog.error("Could not void transaction #{transaction_id}")
        end
      end
    end
  end
end
