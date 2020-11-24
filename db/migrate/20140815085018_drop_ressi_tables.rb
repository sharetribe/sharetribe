class DropRessiTables < ActiveRecord::Migration
  def up
    drop_table :cached_ressi_events if ActiveRecord::Base.connection.table_exists? 'cached_ressi_events'
    drop_table :old_ressi_events if ActiveRecord::Base.connection.table_exists? 'old_ressi_events'
  end

  def down
    create_table :cached_ressi_events, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :user_id
      t.string :application_id
      t.string :session_id
      t.string :ip_address
      t.string :action
      t.text :parameters
      t.string :return_value
      t.text :headers
      t.string :semantic_event_id
      t.integer :test_group_number
      t.integer :community_id
      t.timestamps
    end
  end
end
