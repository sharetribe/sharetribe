class AddDefaultMinDaysBetweenCommunityUpdatesToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :default_min_days_between_community_updates, :integer, :default => 7
  end
end
