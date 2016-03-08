class AddUniqueIndexPersonOnUsernameAndCommunityId < ActiveRecord::Migration
  def change
    remove_index :people, column: :username
    add_index :people, [:username, :community_id], unique: true
  end
end
