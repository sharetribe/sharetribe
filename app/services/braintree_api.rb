#
# This class makes Braintree calls thread-safe even though we're using
# different configurations per Braintree call
#
class BraintreeApi
  class << self

    @@mutex = Mutex.new

    def configure_for(community)
      Braintree::Configuration.environment = community.payment_gateway.braintree_environment.to_sym
      Braintree::Configuration.merchant_id = community.payment_gateway.braintree_merchant_id
      Braintree::Configuration.public_key = community.payment_gateway.braintree_public_key
      Braintree::Configuration.private_key = community.payment_gateway.braintree_private_key
    end

    def reset_configurations
      Braintree::Configuration.merchant_id = nil
      Braintree::Configuration.public_key = nil
      Braintree::Configuration.private_key = nil
    end

    # This method should be used for all actions that require setting correct
    # Merchant details for the Braintree gem
    def with_braintree_config(community, &block)
      @@mutex.synchronize {
        configure_for(community)

        return_value = block.call

        reset_configurations()

        return return_value
      }
    end

    def create_merchant_account(braintree_account, community)
      with_braintree_config(community) do
        Braintree::MerchantAccount.create(
            :applicant_details => {
              :first_name => braintree_account.first_name,
              :last_name => braintree_account.last_name,
              :email => braintree_account.email,
              :phone => braintree_account.phone,
              :address => {
                :street_address => braintree_account.address_street_address,
                :postal_code => braintree_account.address_postal_code,
                :locality => braintree_account.address_locality,
                :region => braintree_account.address_region
              },
              :date_of_birth => braintree_account.date_of_birth,
              :routing_number => braintree_account.routing_number,
              :account_number => braintree_account.account_number
            },
            :tos_accepted => true,
            :master_merchant_account_id => master_merchant_id(community),
            :id => braintree_account.person_id
          )
      end
    end

    def transaction_sale(community, options)
      with_braintree_config(community) do
        Braintree::Transaction.create(options)
      end
    end

    def find_transaction(community, transaction_id)
      with_braintree_config(community) do
        Braintree::Transaction.find(transaction_id)
      end
    end

    def submit_to_settlement(community, transaction_id)
      with_braintree_config(community) do
        Braintree::Transaction.submit_for_settlement(transaction_id)
      end
    end

    def release_from_escrow(community, transaction_id)
      with_braintree_config(community) do
        Braintree::Transaction.release_from_escrow(transaction_id)
      end
    end

    def void_transaction(community, transaction_id)
      with_braintree_config(community) do
        Braintree::Transaction.void(transaction_id)
      end
    end

    def master_merchant_id(community)
      # TODO Move this method, it has nothing to do with the Braintree API
      community.payment_gateway.braintree_master_merchant_id
    end

    def webhook_notification_verify(community, challenge)
      with_braintree_config(community) do
        Braintree::WebhookNotification.verify(challenge)
      end
    end

    def webhook_notification_parse(community, signature, payload)
      with_braintree_config(community) do
        Braintree::WebhookNotification.parse(signature, payload)
      end
    end

    def webhook_testing_sample_notification(community, kind, id)
      with_braintree_config(community) do
        Braintree::WebhookTesting.sample_notification(kind, id)
      end
    end
  end
end
