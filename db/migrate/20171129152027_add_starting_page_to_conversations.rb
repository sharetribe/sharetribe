class AddStartingPageToConversations < ActiveRecord::Migration[5.1]
  def up
    add_column :conversations, :starting_page, :string
    add_index :conversations, :starting_page
    ActiveRecord::Base.connection.execute("UPDATE conversations c LEFT JOIN transactions t ON c.id = t.conversation_id SET c.starting_page = 'profile' WHERE t.id IS NULL")
    ActiveRecord::Base.connection.execute("UPDATE conversations c LEFT JOIN transactions t ON c.id = t.conversation_id SET c.starting_page = 'listing' WHERE t.payment_gateway = 'none' AND t.current_state = 'free'")
    ActiveRecord::Base.connection.execute("UPDATE conversations c LEFT JOIN transactions t ON c.id = t.conversation_id SET c.starting_page = 'payment' WHERE t.payment_gateway != 'none' OR t.current_state != 'free'")
  end

  def down
    remove_index :conversations, :starting_page
    remove_column :conversations, :starting_page
  end
end
