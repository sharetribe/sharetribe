class RemoveReadAndAddIsReadToPersonConversation < ActiveRecord::Migration
  def self.up
    remove_column :person_conversations, :read
    add_column :person_conversations, :is_read, :integer, :default => 0
  end

  def self.down
    remove_column :person_conversations, :is_read
    add_column :person_conversations, :read, :boolean
  end
end
