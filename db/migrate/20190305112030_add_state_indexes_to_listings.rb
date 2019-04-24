class AddStateIndexesToListings < ActiveRecord::Migration[5.1]
  def change
    add_index :listings, [:community_id, :open, :state, :deleted, :valid_until, :sort_date], name: 'listings_homepage_query'
    add_index :listings, [:community_id, :open, :state, :deleted, :valid_until, :updates_email_at, :created_at], name: 'listings_updates_email'

    remove_index :listings, name: 'homepage_query', column: ["community_id", "open", "sort_date", "deleted"]
    remove_index :listings, name: 'updates_email_listings', column: ["community_id", "open", "updates_email_at"]
  end
end
