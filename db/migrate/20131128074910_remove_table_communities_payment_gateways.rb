class RemoveTableCommunitiesPaymentGateways < ActiveRecord::Migration
  def self.up
    drop_table :communities_payment_gateways
  end

  def self.down
    create_table :communities_payment_gateways, :id => false do |t|
      t.integer :community_id
      t.integer :payment_gateway_id
    end
  end
end
