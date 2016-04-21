class RemoveIndicesForMigrations < ActiveRecord::Migration
  def change
    remove_index :people, column: :cloned_from
    remove_index :comments, column: :author_id
    remove_index :comments, column: :community_id
    remove_index :transactions, column: :starter_id
    remove_index :transactions, column: :listing_author_id
    remove_index :messages, column: :sender_id
    remove_index :feedbacks, column: :author_id
    remove_index :feedbacks, column: :community_id
    remove_index :listings, column: :author_id
    remove_index :listing_images, column: :author_id
    remove_index :payments, column: :recipient_id
    remove_index :braintree_accounts, column: :person_id
    remove_index :paypal_payments, column: :merchant_id
    remove_index :paypal_tokens, column: :merchant_id
  end
end
