class AddDefaultMinDaysBetweenCommunityUpdatesToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :default_min_days_between_community_updates, :integer, :default => 7
  end
end
