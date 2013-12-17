class RenamePaymentGatewayIdToType < ActiveRecord::Migration
  class CommunityPaymentGateway < ActiveRecord::Base
    # Just empty class to make the migration through even if that class is already deleted when running this.
  end
  
  def up
    add_column :community_payment_gateways, :type, :string, :after => :payment_gateway_id

    # Reload
    CommunityPaymentGateway.reset_column_information

    # Add type
    CommunityPaymentGateway.find_each do |gateway|
      type = case gateway.payment_gateway_id
        when 1
          "Mangopay"
        when 3
          "BraintreePaymentGateway"
        else
          # Checkout, id 2 and default
          "Checkout"
        end

      gateway.update_column(:type, type)
    end

    remove_column :community_payment_gateways, :payment_gateway_id
  end

  def down
    add_column :community_payment_gateways, :payment_gateway_id, :int, :after => :type

    # Reload
    CommunityPaymentGateway.reset_column_information

    puts "WARNING! The down step does NOT migrate the payment gateway id data"

    remove_column :community_payment_gateways, :type
  end
end
