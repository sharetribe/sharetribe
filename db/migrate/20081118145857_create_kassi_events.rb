class CreateKassiEvents < ActiveRecord::Migration
  def self.up
    create_table :kassi_events do |t|
      t.string :receiver_id
      t.string :realizer_id
      t.references :eventable, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :kassi_events
  end
end
