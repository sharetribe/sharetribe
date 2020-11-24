class CreatePersonConversations < ActiveRecord::Migration
  def self.up
    create_table :person_conversations do |t|
      t.string :person_id
      t.integer :conversation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :person_conversations
  end
end
