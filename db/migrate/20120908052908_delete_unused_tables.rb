class DeleteUnusedTables < ActiveRecord::Migration
  def self.up
    remove_column :listings, :close_notification_sent
    drop_table :favors
    drop_table :filters
    drop_table :items
    drop_table :kassi_events
    drop_table :kassi_event_participations
    drop_table :kassi_events_people
    drop_table :listing_comments
    drop_table :people_smerf_forms
    drop_table :person_comments
    drop_table :person_conversations
    drop_table :person_interesting_listings
    drop_table :person_read_listings
    drop_table :settings
    drop_table :smerf_forms
    drop_table :smerf_responses
    drop_table :transactions
    
  end

  def self.down
    #add_column :listings, :close_notification_sent, :boolean, :default => 0
    raise  ActiveRecord::IrreversibleMigration, "This migration deletes whole tables which are no longer in use, so it doesn't seem useful to build the complete rollback for this. If needed, it's possible to build and add here."
  end
end
