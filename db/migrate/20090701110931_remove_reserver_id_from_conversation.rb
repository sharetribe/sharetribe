class RemoveReserverIdFromConversation < ActiveRecord::Migration
  def self.up
    remove_column :conversations, :reserver_id
  end

  def self.down
    add_column :conversations, :reserver_id, :string
  end
end
