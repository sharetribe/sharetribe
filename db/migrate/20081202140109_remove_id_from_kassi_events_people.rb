class RemoveIdFromKassiEventsPeople < ActiveRecord::Migration
  def self.up
    drop_table :kassi_events_people
    create_table :kassi_events_people, :id => false do |t|
      t.string :person_id
      t.string :kassi_event_id
    end
  end

  def self.down
    drop_table :kassi_events_people
    create_table :kassi_events_people do |t|
      t.string :person_id
      t.string :kassi_event_id
      
      t.timestamps
    end
  end
end
