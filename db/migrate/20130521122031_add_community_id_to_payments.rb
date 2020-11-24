class AddCommunityIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :community_id, :integer
  end
end
