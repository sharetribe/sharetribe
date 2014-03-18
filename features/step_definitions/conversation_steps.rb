Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  # Hard-coded to the first community. Change this if needed
  community = @listing.communities.first

  @conversation = Conversation.create!(:listing_id => @listing.id, 
                                      :title => message,
                                      :status => "pending", 
                                      :conversation_participants => { @listing.author.id => "false", @people[sender].id => "true"},
                                      :message_attributes => { :content => message, :sender_id => @people[sender].id },
                                      :community => community
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

Then /^the status of the conversation should be "([^"]*)"$/ do |status|
  @conversation.status.should == status 
end

Given /^the (offer|request) is (accepted|rejected|confirmed|canceled|paid)$/ do |listing_type, status|
  @conversation.update_attribute(:status, status)

  if listing_type == "request" && @conversation.community.payment_possible_for?(@conversation.listing)
    if status == "accepted"
      # In this case there should be a pending payment done when this got accepted.
      FactoryGirl.create(:payment, :conversation => @conversation, :recipient => @conversation.listing.author, :status => "pending", :sum => @conversation.listing.price)
    end

    if status == "paid"
      # In this case there should be a pending payment done when this got accepted.
      FactoryGirl.create(:payment, :conversation => @conversation, :recipient => @conversation.listing.author, :status => "paid", :sum => @conversation.listing.price)
    end
  end
end



Given(/^that conversation will be automatically confirmed after (\d+) days$/) do |automatic_confirmation_after_days|
  @conversation.update_attribute(:automatic_confirmation_after_days, automatic_confirmation_after_days)

  conversation = @conversation
  user = @conversation.offerer
  community = @conversation.community
  
  ConfirmConversation.new(conversation, user, community).activate_automatic_confirmation!
end

When /^there is feedback about that event from "([^"]*)" with grade "([^"]*)" and with text "([^"]*)"$/ do |feedback_giver, grade, text|
  participation = @conversation.participations.find_by_person_id(@people[feedback_giver].id)
  Testimonial.create!(:grade => grade, :author_id => @people[feedback_giver].id, :text => text, :participation_id => participation.id, :receiver_id => @conversation.other_party(@people[feedback_giver]).id)
end

Then /^I should see information about missing payment details$/ do
  find("#conversation-payment-details-missing").should be_visible
end

When(/^I skip feedback$/) do
  steps %Q{
    When I click "#do_not_give_feedback"
    And I press submit
  }
end

Given /^I'm on the conversation page of that conversation$/ do
  steps %Q{
    Given I am on the conversation page of "#{@conversation.id}"
  }
end

Then(/^I should see that the conversation is waiting for confirmation$/) do
  steps %Q{
    Then I should see "Accepted"
    Then I should see "Waiting for"
    Then I should see "to mark the request as completed"
  }
end

Then(/^the requester of that conversation should receive an email with subject "([^"]*)"$/) do |subject|
  recipient = @conversation.requester
  email = recipient.confirmed_notification_email_addresses.first

  steps %Q{
    Then "#{email}" should receive an email with subject "#{subject}"
  }
end

Then(/^the offerer of that conversation should receive an email with subject "([^"]*)"$/) do |subject|
  recipient = @conversation.offerer
  email = recipient.confirmed_notification_email_addresses.first

  steps %Q{
    Then "#{email}" should receive an email with subject "#{subject}"
  }
end

Then(/^the requester of that conversation should receive an email about unconfirmed listing$/) do
  steps %Q{
    Then the requester of that conversation should receive an email with subject "Remember to confirm or cancel a request"
  }
end

Then(/^the (buyer|requester) of that conversation should receive an email about automatically confirmed listing$/) do |_|
  steps %Q{
    Then the requester of that conversation should receive an email with subject "Request automatically completed - remember to give feedback"
  }
end

Then(/^the (offerer|seller) of that conversation should receive an email confirmed listing$/) do |_|
  steps %Q{
    Then the offerer of that conversation should receive an email with subject "Request completed - remember to give feedback"
  }
end

Then(/^the buyer of that conversation should receive an email about unconfirmed listing with escrow$/) do
  steps %Q{
    Then the requester of that conversation should receive an email with subject "Remember to confirm or cancel a request"
    When I open the email with subject "Remember to confirm or cancel a request"
    Then I should see "a) you have marked the request completed" in the email body
    And I should see "b) 14 days have passed since you paid" in the email body
    And I should see "you have 2 days to" in the email body
    And I should see "cancel it" in the email body
  }
end

Then(/^I should see that the conversation is confirmed$/) do
  steps %Q{
    Then I should see "Completed"
    Then I should see "Give feedback"
    Then I should see "Skip feedback"
  }
end