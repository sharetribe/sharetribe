module ConversationsHelper
  
  def get_message_title(listing)
    t(".#{listing.listing_type}_message_title", :title => @listing.title)
  end
  
end
