module ConversationsHelper
  
  def get_message_title(listing)
    t(".#{listing.category}_#{listing.listing_type}_message_title", :title => @listing.title)
  end
  
  # Class is selected if conversation type is currently selected
  def get_inbox_tab_class(tab_name)
    current_tab_name = params[:conversation_type] || action_name || "received"
    current_tab_name = "received" if current_tab_name.eql?("show")
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
  
end
