class AddReservationFieldsToConversations < ActiveRecord::Migration
  def self.up
    add_column :conversations, :type, :string, :default => 'Conversation'
    add_column :conversations, :reserver_name, :string
    add_column :conversations, :reserver_id, :string
    add_column :conversations, :pick_up_time, :date
    add_column :conversations, :return_time, :date
    add_column :conversations, :status, :string
    add_column :conversations, :hidden_from_owner, :integer, :default => 0
    add_column :conversations, :hidden_from_reserver, :integer, :default => 0     
  end

  def self.down
    remove_column :conversations, :type
    remove_column :conversations, :reserver_name
    remove_column :conversations, :reserver_id
    remove_column :conversations, :pick_up_time
    remove_column :conversations, :return_time
    remove_column :conversations, :status
    remove_column :conversations, :hidden_from_owner
    remove_column :conversations, :hidden_from_reserver
  end
end
