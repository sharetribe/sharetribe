class AddCommunityIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :community_id, :integer, after: :person_id
    add_index :emails, :community_id
  end
end

