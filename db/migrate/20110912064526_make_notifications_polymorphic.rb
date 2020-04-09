class MakeNotificationsPolymorphic < ActiveRecord::Migration[5.2]
def self.up
    add_column :notifications, :notifiable_id, :integer
    add_column :notifications, :notifiable_type, :string
  end

  def self.down
    remove_column :notifications, :notifiable_id
    remove_column :notifications, :notifiable_type
  end
end
