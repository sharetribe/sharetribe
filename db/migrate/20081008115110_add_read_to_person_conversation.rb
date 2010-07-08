class AddReadToPersonConversation < ActiveRecord::Migration
  def self.up
    add_column :person_conversations, :read, :boolean, :default => 0
  end

  def self.down
    remove_column :person_conversations, :read
  end
end
