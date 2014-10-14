module BraintreeService
  module Payments
    CommunityModel = ::Community

    module Entity
      #in db these can be null.
      BraintreeSettings = EntityUtils.define_builder(
        [:environment, :mandatory, :symbol],
        [:merchant_id, :mandatory, :string],
        [:public_key,  :mandatory, :string],
        [:private_key, :mandatory, :string],
        [:braintree_client_side_encryption_key, :mandatory, :string]
      )

      module_function

      def braintree_settings(payment_gateway)

        BraintreeSettings[
          environment: payment_gateway.braintree_environment.to_sym,
          merchant_id: payment_gateway.braintree_merchant_id,
          public_key: payment_gateway.braintree_public_key,
          private_key: payment_gateway.braintree_private_key,
          braintree_client_side_encryption_key: payment_gateway.braintree_client_side_encryption_key
        ]
      end
    end

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

    module Query

      module_function

      def braintree_settings(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
          .map { |community|
            if community.payment_gateway.present? && community.payment_gateway.gateway_type == :braintree
              BraintreeService::Payments::Entity.braintree_settings(community.payment_gateway)
            else
              nil
            end
          }
          .or_else(nil)
      end
    end
  end
end
