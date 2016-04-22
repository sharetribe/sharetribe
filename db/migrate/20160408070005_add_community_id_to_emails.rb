class AddCommunityIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :community_id, :integer, after: :person_id
  end
end
