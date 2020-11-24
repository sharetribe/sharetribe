class AddEventFeedEnabledToCommunities < ActiveRecord::Migration
  def self.up
    add_column :communities, :event_feed_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :communities, :event_feed_enabled
  end
end
