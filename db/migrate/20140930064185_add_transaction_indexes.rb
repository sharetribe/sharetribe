class AddTransactionIndexes < ActiveRecord::Migration
  def change
    add_index :transactions, :listing_id
    add_index :transactions, :conversation_id
    add_index :transactions, :community_id
    add_index :conversations, :community_id
    add_index :listings, :transaction_type_id
    add_index :testimonials, :transaction_id
    add_index :testimonials, :author_id
  end
end
