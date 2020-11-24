class CreateCachedRessiEvents < ActiveRecord::Migration
  def self.up
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

      t.timestamps
    end
  end

  def self.down
    drop_table :cached_ressi_events
  end
end

