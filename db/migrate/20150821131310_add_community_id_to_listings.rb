class AddCommunityIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :community_id, :integer, after: :id
  end
end
