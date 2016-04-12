class AddCommunityIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :community_id, :integer, { after: :id }
    add_index :people, :community_id
  end
end
