class DropNotificationsTable < ActiveRecord::Migration[5.2]
def up
    drop_table :notifications
  end

  def down
  end
end
