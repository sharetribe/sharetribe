class AddClonedFromAndIndicesForMigrations < ActiveRecord::Migration
  def change
    # Add column
    add_column :people, :cloned_from, :string, { limit: 22 }

    # Add indices
    add_index :people, :cloned_from
    add_index :comments, :author_id
    add_index :comments, :community_id
    add_index :transactions, :starter_id
    add_index :transactions, :listing_author_id
    add_index :messages, :sender_id
    add_index :feedbacks, :author_id
    add_index :feedbacks, :community_id
    add_index :listings, :author_id
    add_index :listing_images, :author_id
    add_index :payments, :recipient_id
    add_index :braintree_accounts, :person_id
    add_index :paypal_payments, :merchant_id
    add_index :paypal_tokens, :merchant_id
  end
end
