Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  title = I18n.t("conversations.new.#{@listing.category}_#{@listing.listing_type}_message_title", :title => @listing.title)
  @conversation = Conversation.create!(:listing_id => @listing.id, 
                                      :title => title, 
                                      :conversation_participants => { @listing.author.id => "false", @people[sender].id => "true"},
                                      :message_attributes => { :content => message, :sender_id => @people[sender].id }
                                      )                                   
end

Given /^there is a reply "([^"]*)" to that message by "([^"]*)"$/ do |content, sender|
  @message = Message.create!(:conversation_id => @conversation.id, 
                            :sender_id => @people[sender].id, 
                            :content => content
                           )                                   
end

When /^I try to go to inbox of "([^"]*)"$/ do |person|
  visit received_person_messages_path(:locale => :en, :person_id => @people[person].id)
end
