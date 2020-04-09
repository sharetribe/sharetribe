class AddNewIndexes < ActiveRecord::Migration[5.2]
def up
    add_index :communities_payment_gateways, :community_id
  end

  def down
    remove_index :communities_payment_gateways, :community_id
  end
end
