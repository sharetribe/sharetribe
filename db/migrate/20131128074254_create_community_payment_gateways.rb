class CreateCommunityPaymentGateways < ActiveRecord::Migration
  def change
    create_table :community_payment_gateways do |t|
      t.integer :community_id
      t.integer :payment_gateway_id
      t.string :braintree_merchant_id
      t.string :braintree_master_merchant_id
      t.string :braintree_public_key
      t.string :braintree_private_key

      t.timestamps
    end
  end
end
