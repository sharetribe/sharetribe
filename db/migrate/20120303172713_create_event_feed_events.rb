class CreateEventFeedEvents < ActiveRecord::Migration
  def self.up
    create_table :event_feed_events do |t|
      t.string :person1_id
      t.string :person2_id
      t.string :community_id
      t.integer :eventable_id
      t.string :eventable_type
      t.string :category
      t.boolean :members_only, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :event_feed_events
  end
end
