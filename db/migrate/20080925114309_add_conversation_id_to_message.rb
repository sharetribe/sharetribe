class AddConversationIdToMessage < ActiveRecord::Migration[5.2]
  def self.up
    add_column :messages, :conversation_id, :integer
  end

  def self.down
    remove_column :messages, :conversation_id
  end
end
