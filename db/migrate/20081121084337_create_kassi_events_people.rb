class CreateKassiEventsPeople < ActiveRecord::Migration
  def self.up
    create_table :kassi_events_people do |t|
      t.string :person_id
      t.string :kassi_event_id
      
      t.timestamps
    end
  end

  def self.down
      drop_table :kassi_events
  end
end
