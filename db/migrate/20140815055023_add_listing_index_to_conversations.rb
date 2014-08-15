class AddListingIndexToConversations < ActiveRecord::Migration
  def change
    add_index :conversations, :listing_id
  end
end
