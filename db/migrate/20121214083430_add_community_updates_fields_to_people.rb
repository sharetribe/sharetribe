class AddCommunityUpdatesFieldsToPeople < ActiveRecord::Migration
  def up
    add_column :people, :community_updates_last_sent_at, :datetime
    add_column :people, :min_days_between_community_updates, :integer, :default => 1
  end
  
  def down
    remove_column :people, :community_updates_last_sent_at
    remove_column :people, :min_days_between_community_updates
  end
end
