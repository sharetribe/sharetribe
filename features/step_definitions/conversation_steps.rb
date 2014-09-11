def create_transaction(community, listing, starter, message)
  conversation = FactoryGirl.build(:conversation,
    community: community,
    listing: listing)

  conversation.participations.build({
    person_id: starter.id,
    is_starter: true
  })

  conversation.participations.build({
    person_id: listing.author.id,
    is_starter: false
  })

  conversation.messages.build({
    content: message,
    sender: starter
  })

  transaction = FactoryGirl.create(:transaction,
    listing: listing,
    community: community,
    starter: starter,
    conversation: conversation
  )
end

Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  @conversation = create_transaction(@current_community, @listing, @people[sender], message)
end

Given /^there is a pending request "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  @conversation = create_transaction(@current_community, @listing, @people[sender], message)
  @conversation.transition_to! "pending"
end

Given /^there is a reply "([^"]*)" to that message by "([^"]*)"$/ do |content, sender|
  @message = Message.create!(:conversation_id => @conversation.id,
                            :sender_id => @people[sender].id,
                            :content => content
                           )
end

When /^I try to go to inbox of "([^"]*)"$/ do |person|
  visit person_inbox_path(:locale => :en, :person_id => @people[person].id)
end

Then /^the status of the conversation should be "([^"]*)"$/ do |status|
  @conversation.status.should == status
end

Given /^the (offer|request) is (accepted|rejected|confirmed|canceled|paid)$/ do |listing_type, status|
  if listing_type == "request" && @conversation.listing.payment_required_at?(@conversation.community)
    if status == "accepted" || status == "paid"
      # In this case there should be a pending payment done when this got accepted.
      type = if @conversation.community.payment_gateway.type == "BraintreePaymentGateway"
        :braintree_payment
      else
        :checkout_payment
      end

      recipient = @conversation.listing.author

      if @conversation.payment == nil
        payment = FactoryGirl.build(type, :conversation => @conversation, :recipient => recipient, :status => "pending", :community => @current_community)
        payment.default_sum(@conversation.listing, 24)
        payment.save!

        @conversation.payment = payment
      end
    end
  end

  # TODO Change status step by step
  if @conversation.status == "pending" && status == "confirmed"
    @conversation.update_attribute(:status, "accepted")
    @conversation.payment.update_attribute(:status, "paid") if @conversation.payment
    @conversation.update_attribute(:status, "paid") if @conversation.payment
    @conversation.update_attribute(:status, "confirmed")
  elsif @conversation.status == "pending" && status == "paid"
    @conversation.update_attribute(:status, "accepted")
    @conversation.payment.update_attribute(:status, "paid") if @conversation.payment
    @conversation.update_attribute(:status, "paid") if @conversation.payment
  elsif @conversation.status == "not_started" && status == "accepted"
    @conversation.update_attribute(:status, "pending")
    @conversation.update_attribute(:status, "accepted")
  else
    @conversation.update_attribute(:status, status)
  end
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
    Then I should see "to mark the request completed"
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

When(/^I open message "(.*?)"$/) do |title|
  steps %Q{
    When I follow "#{title}" within "h2"
  }
end

Then(/^I should see that the request is waiting for seller acceptance$/) do
  page.should have_content(/Waiting for (.*) to accept the request/)
end

def visit_conversation_of_listing(listing)
  conversation = Conversation.find_by_listing_id(listing.id)
  visit(single_conversation_path(:person_id => @current_user.id, :conversation_type => "received", :id => conversation.id, :locale => "en"))
end

When(/^I accepts the request for that listing$/) do
  visit_conversation_of_listing(@listing)
  click_link "Accept request"
  click_button "Approve"
end


Then(/^I should see that the request is waiting for buyer confirmation$/) do
  page.should have_content(/Waiting for (.*) to mark the request completed/)
end

Then /^I should see that I should now deliver the board$/ do
  page.should have_content(/Waiting for you to deliver (.*)/)
end

Then(/^I should see that the request is confirmed/) do
  page.should have_content(/marked the request as completed/)
end

When(/^I accept the "(.*?)" request for that listing for post pay$/) do |request|
  click_link "inbox-link"
  click_link request
  click_link "Accept request"
end

When(/^I approve the request for that listing for post pay$/) do
  click_button "Send"
end

Then(/^I should see that I should fill in payout details$/) do
  expect(find(:link, "payment settings"))
end

Then(/^I should see that the request is waiting for buyer to pay$/) do
  page.should have_content(/Waiting for (.*) to pay/)
end

When(/^I pay my request for that listing$/) do
  visit_conversation_of_listing(@listing)
  click_link "Pay"
end

When(/^I buy approved request "(.*)"$/) do |accepted_request|
  click_link "inbox-link"
  click_link accepted_request
  click_link "Pay"
end

When(/^I confirm the request for that listing$/) do
  visit_conversation_of_listing(@listing)
  click_link "Mark completed"
  choose("Skip feedback")
  click_button "Continue"
end

Then(/^I should see that the request was confirmed$/) do
  page.should have_content(/Completed/)
end

When(/^the seller does not respond the request within (\d+) days$/) do |days|
  Timecop.travel(DateTime.now + (days.to_i + 1))
  process_jobs
  visit(current_path)
end

Then(/^I should see that the request was rejected$/) do
  page.should have_content(/Rejected/)
end


Then /^I should see that the price of a listing is "(.*?)"$/ do |price_string|
  expect(find(".message-price")).to have_content(price_string)
end

Then /^I should send a message to "(.*?)"$/ do |seller_name|
  find("#new_listing_conversation").visible?.should be_true
  seller = Person.find_by_username(seller_name)
  expect(find("label[for=listing_conversation_message_attributes_content]")).to have_content("Message to #{seller.given_name}")
end

When /^I send initial message to "(.*?)"$/ do |seller|
  fill_in "listing_conversation[message_attributes][content]", :with => "I want to buy this item"
  click_button("Buy")
end

Then /^I should see that buy message has been sent$/ do
  expect(page).to have_content("Message sent")
end

When /^I follow link to fill in Braintree payout details$/ do
  click_link("#conversation-payment-settings-link")
end

Then /^I should see that the total price is "(.*?)"$/ do |total_price|
  expect(page).to have_content("Total: $#{total_price}")
end

When /^the booking is automatically confirmed$/ do
  Timecop.travel(@booking_end_date + 2.days)
  process_jobs
  visit(current_path)
end

Then /^I should see that the request is completed$/ do
  expect(page.find(".conversation-status")).to have_content("Completed")
end

