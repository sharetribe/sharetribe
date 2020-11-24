class CreateKassiEventParticipations < ActiveRecord::Migration
  def self.up
    create_table :kassi_event_participations do |t|
      t.integer :kassi_event_id
      t.string :person_id
      t.string :role

      t.timestamps
    end
  end

  def self.down
    drop_table :kassi_event_participations
  end
end
