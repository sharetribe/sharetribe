class AddIndexUniqueCommunityIdAndUsername < ActiveRecord::Migration
  def change
    add_index :people, [:username, :community_id], unique: true
  end
end
