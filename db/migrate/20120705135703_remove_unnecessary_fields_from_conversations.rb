class RemoveUnnecessaryFieldsFromConversations < ActiveRecord::Migration
  def self.up
    remove_column :conversations, :reserver_name
    remove_column :conversations, :pick_up_time
    remove_column :conversations, :return_time
    remove_column :conversations, :hidden_from_owner
    remove_column :conversations, :hidden_from_reserver
    remove_column :conversations, :favor_id
  end

  def self.down
    add_column :conversations, :reserver_name, :string
    add_column :conversations, :pick_up_time, :date
    add_column :conversations, :return_time, :date
    add_column :conversations, :hidden_from_owner, :integer, :default => 0
    add_column :conversations, :hidden_from_reserver, :integer, :default => 0
    add_column :conversations, :favor_id, :integer
  end
end
