class AddIndexUniqueCommunityIdAndFacebookId < ActiveRecord::Migration
  def change
    # Remove the old facebook_id from index because we don't
    # do searches with facebook id only
    remove_index :people, column: :facebook_id
    add_index :people, [:facebook_id, :community_id], unique: true
  end
end
