class AddNewIndexes < ActiveRecord::Migration
  def up
    add_index :communities_payment_gateways, :community_id
  end

  def down
    remove_index :communities_payment_gateways, :community_id
  end
end
