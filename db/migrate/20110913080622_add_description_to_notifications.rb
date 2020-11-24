class AddDescriptionToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :description, :string
  end

  def self.down
    remove_column :notifications, :description
  end
end
