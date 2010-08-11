Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  title = I18n.t("conversations.new.#{@listing.category}_#{@listing.listing_type}_message_title", :title => @listing.title)
  @conversation = Conversation.create(:listing_id => @listing.id, 
                                      :title => title, 
                                      :conversation_participants => { @listing.author.id => "false", @people[sender].id => "true"},
                                      :message_attributes => { :content => message, :sender_id => @people[sender].id }
                                      )                                   
end

