class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :devices
    drop_table :event_feed_events
    drop_table :groups
    drop_table :groups_favors
    drop_table :groups_items
    drop_table :groups_listings
    drop_table :item_reservations
    drop_table :organization_memberships
    drop_table :organizations
    drop_table :taggings
    drop_table :tags
  end

  def down
  end
end
