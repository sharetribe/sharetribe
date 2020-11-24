class ChangeTypeToListingConversation < ActiveRecord::Migration
  def up
    Conversation.update_all("type = 'ListingConversation'", "listing_id IS NOT NULL")
  end

  def down
  end
end
