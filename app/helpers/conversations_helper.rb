module ConversationsHelper
  
  def get_message_title(listing)
    t("conversations.new.#{listing.category}_#{listing.listing_type}_message_title", :title => listing.title)
  end
  
  def transaction_proposal_form_title(listing)
    "#{listing.category}_#{listing.listing_type}#{listing.share_type? ? '_' + @listing.share_type : ''}_message_form_title"
  end
  
end
