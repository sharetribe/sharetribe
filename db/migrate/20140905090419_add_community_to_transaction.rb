class AddCommunityToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :community_id, :integer, null: false
  end
end
