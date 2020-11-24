class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :receiver_id
      t.string :type
      t.boolean :is_read, :default => 0
      t.integer :badge_id

      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
