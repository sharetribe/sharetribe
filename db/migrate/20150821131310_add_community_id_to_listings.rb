class AddCommunityIdToListings < ActiveRecord::Migration[5.2]
def change
    add_column :listings, :community_id, :integer, after: :id
    add_index :listings, :community_id
  end
end
