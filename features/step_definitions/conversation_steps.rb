def build_conversation(community, listing, starter, message)
  conversation = FactoryGirl.build(:conversation,
    community: community,
    listing: listing )

  conversation.participations.build({
    person_id: starter.id,
    is_starter: true,
    is_read: true
  })

  conversation.participations.build({
    person_id: listing.author.id,
    is_starter: false,
    is_read: false
  })

  conversation.messages.build({
    content: message,
    sender: starter
  })

  conversation
end

def create_transaction(community, listing, starter, message, payment_gateway = :none)
  transaction = FactoryGirl.create(:transaction,
    listing: listing,
    community: community,
    starter: starter,
    conversation: build_conversation(community, listing, starter, message),
    payment_gateway: payment_gateway,
    payment_process: TransactionProcess.find(listing.transaction_process_id).process == :preauthorize ? :preauthorize : :postpay,
    automatic_confirmation_after_days: community.automatic_confirmation_after_days
  )
end

Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  @transaction = create_transaction(@current_community, @listing, @people[sender], message)
  @conversation = @transaction.conversation
  MarketplaceService::Transaction::Command.transition_to(@transaction.id, "free")
  @transaction.reload
end

Given /^there is a pending request "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  @transaction = create_transaction(@current_community, @listing, @people[sender], message, @current_community.payment_gateway.gateway_type)
  @conversation = @transaction.conversation
  MarketplaceService::Transaction::Command.transition_to(@transaction.id, "pending")
  @transaction.reload
end

Given /^there is a reply "([^"]*)" to that message by "([^"]*)"$/ do |content, sender|
  @conversation.messages.create(
    sender: @people[sender],
    content: content
  )
end

When /^I try to go to inbox of "([^"]*)"$/ do |person|
  visit person_inbox_path(:locale => :en, :person_id => @people[person].id)
end

Then /^the status of the conversation should be "([^"]*)"$/ do |status|
  @transaction.status.should == status
end

Given /^the (offer|request) is (accepted|rejected|confirmed|canceled|paid)$/ do |listing_type, status|
  if listing_type == "request" && @transaction.listing.payment_required_at?(@transaction.community)
    if status == "accepted" || status == "paid"
      # In this case there should be a pending payment done when this got accepted.
      payment_gateway_type = @transaction.community.payment_gateway.type
      type = if payment_gateway_type == "BraintreePaymentGateway"
               :braintree_payment
             else
               raise ArgumentError.new("Unknown payment_gateway.type: #{payment_gateway_type}")
             end

      recipient = @transaction.listing.author

      if @transaction.payment == nil
        payment = FactoryGirl.build(type, tx: @transaction, recipient: recipient, status: "pending", community: @current_community)
        payment.default_sum(@transaction.listing, 24)
        payment.save!

        @transaction.payment = payment
      end
    end
  end

  # TODO Change status step by step
  if @transaction.status == "pending" && status == "confirmed"
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :accepted)
    @transaction.payment.update_attribute(:status, "paid") if @transaction.payment
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :paid) if @transaction.payment
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :confirmed)
  elsif @transaction.status == "pending" && status == "paid"
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :accepted)
    @transaction.payment.update_attribute(:status, "paid") if @transaction.payment
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :paid) if @transaction.payment
  elsif @transaction.status == "not_started" && status == "accepted"
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :pending)
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, :accepted)
  else
    MarketplaceService::Transaction::Command.transition_to(@transaction.id, status.to_sym)
  end

  @transaction.reload
end

When /^there is feedback about that event from "([^"]*)" with grade "([^"]*)" and with text "([^"]*)"$/ do |feedback_giver, grade, text|
  Testimonial.create!(
    grade: grade,
    author_id: @people[feedback_giver].id,
    text: text,
    receiver_id: @transaction.other_party(@people[feedback_giver]).id,
    transaction_id: @transaction.id)
end

Then /^I should see information about missing payment details$/ do
  expect(find("#conversation-payment-details-missing")).to be_visible
end

When(/^I skip feedback$/) do
  steps %Q{
    When I click "#do_not_give_feedback"
    And I press submit
  }
end

Given /^I'm on the transaction page of that transaction$/ do
  steps %Q{
    Given I am on the transaction page of "#{@transaction.id}"
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
  recipient = @transaction.buyer
  email = recipient.confirmed_notification_email_addresses.first

  steps %Q{
    Then "#{email}" should receive an email with subject "#{subject}"
  }
end

Then(/^the offerer of that conversation should receive an email with subject "([^"]*)"$/) do |subject|
  recipient = @transaction.seller
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
    Then the requester of that conversation should receive an email with subject "Order automatically completed - remember to give feedback"
  }
end

Then(/^the (offerer|seller) of that conversation should receive an email confirmed listing$/) do |_|
  steps %Q{
    Then the offerer of that conversation should receive an email with subject "Order completed - remember to give feedback"
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
  expect(page).to have_content(/Waiting for (.*) to accept the request/)
end

def visit_transaction_of_listing(listing)
  transaction = Transaction.find_by_listing_id(listing.id)
  visit(person_transaction_path(:person_id => @current_user.id, :id => transaction.id, :locale => "en"))
end

When(/^I accepts the request for that listing$/) do
  visit_transaction_of_listing(@listing)
  click_link "Accept request"
  click_button "Accept"
end


Then(/^I should see that the order is waiting for buyer confirmation$/) do
  expect(page).to have_content(/Waiting for (.*) to mark the order completed/)
end

Then(/^I should see that the order is confirmed/) do
  expect(page).to have_content(/marked the order as completed/)
end

When(/^I pay my request for that listing$/) do
  visit_transaction_of_listing(@listing)
  click_link "Pay"
end

When(/^I confirm the request for that listing$/) do
  visit_transaction_of_listing(@listing)
  click_link "Mark completed"
  choose("Skip feedback")
  click_button "Continue"
end

Then(/^I should see that the request was confirmed$/) do
  expect(page).to have_content(/Completed/)
end

When(/^the seller does not respond the request within (\d+) days$/) do |days|
  Timecop.travel(DateTime.now + (days.to_i + 1))
  process_jobs
  visit(current_path)
end

Then(/^I should see that the request was rejected$/) do
  expect(page).to have_content(/Rejected/)
end

Then /^I should see "(.*?)" in the message list$/ do |msg|
  expect(page.find("#messages")).to have_content(msg)
end
