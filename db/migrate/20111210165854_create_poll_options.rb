class CreatePollOptions < ActiveRecord::Migration
  def self.up
    create_table :poll_options do |t|
      t.string :label
      t.integer :poll_id
      t.float :percentage

      t.timestamps
    end
  end

  def self.down
    drop_table :poll_options
  end
end
