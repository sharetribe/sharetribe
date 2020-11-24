class AddIndexUniqueCommunityIdAndEmailAddress < ActiveRecord::Migration
  def change
    add_index :emails, [:address, :community_id], unique: true
  end
end
