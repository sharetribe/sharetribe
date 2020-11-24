class AddIndexUniqueCommunityIdAndFacebookId < ActiveRecord::Migration
  def change
    add_index :people, [:facebook_id, :community_id], unique: true
  end
end
