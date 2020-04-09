class AddCommunityIdToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :community_id, :integer
  end
end
