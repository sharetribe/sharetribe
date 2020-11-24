class CreateCommunitiesPaymentGateways < ActiveRecord::Migration
  def change
    create_table :communities_payment_gateways, :id => false do |t|
      t.integer :community_id
      t.integer :payment_gateway_id
    end
  end
end
