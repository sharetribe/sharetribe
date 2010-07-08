class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :email_when_new_message, :default => 1
      t.integer :email_when_new_comment, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
