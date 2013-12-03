#
# This class makes Braintree calls thread-safe even though we're using
# different configurations per Braintree call
#
class BraintreeService
  class << self
    mutex = Mutex.new


    
    
    # Give `community` and set Braintree configurations
    def configure_for(community)
      # TODO
    end

    # Reset Braintree configurations
    def reset_configurations()
      # TODO
    end


    
    def create_merchant_account(braintree_account, community)
      with_braintree_config(community) do
        merchant_account_result = Braintree::MerchantAccount.create(
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
              :ssn => braintree_account.ssn,
              :routing_number => braintree_account.routing_number,
              :account_number => braintree_account.account_number
            },
            :tos_accepted => true,
          
            :master_merchant_account_id => master_merchant_id(community),
          )

        if merchant_account_result.success?
          puts "success!: created merchant account"
          puts merchant_account_result.merchant_account.inspect
          return merchant_account_result.merchant_account.id
        else
          puts "error: in creating merchant account"
          p merchant_account_result.errors
          throw "error: in creating merchant account"
        end
      end
    end
    
    def master_merchant_id(community)
      community.payment_gateways.first.braintree_master_merchant_id
    end
    
    private
    
    def with_braintree_config(community, &block)
      
      mutex.synchronize {
        configure_for(community)

        return_value = block.call

        reset_configurations()
      }
      return return_value

    end
    
    def configure_for(community)
      Braintree::Configuration.environment = :sandbox
      Braintree::Configuration.merchant_id = community.payment_gateways.first.braintree_merchat_id
      Braintree::Configuration.public_key = community.payment_gateways.first.braintree_public_key
      Braintree::Configuration.private_key = community.payment_gateways.first.braintree_private_key
    end
    
    def reset_configurations
      Braintree::Configuration.merchant_id = nil
      Braintree::Configuration.public_key = nil
      Braintree::Configuration.private_key = nil
    end
  end
end