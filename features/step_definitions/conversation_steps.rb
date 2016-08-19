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

Given /^there is a reply "([^"]*)" to that message by "([^"]*)"$/ do |content, sender|
  @conversation.messages.create(
    sender: @people[sender],
    content: content
  )
end

When /^I try to go to inbox of "([^"]*)"$/ do |person|
  visit person_inbox_path(:locale => :en, :person_id => @people[person].id)
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

Then(/^I should see that the conversation is waiting for confirmation$/) do
  steps %Q{
    Then I should see "Accepted"
    Then I should see "Waiting for"
    Then I should see "to mark the request completed"
  }
end

When(/^I open message "(.*?)"$/) do |title|
  steps %Q{
    When I follow "#{title}" within "h2"
  }
end

def visit_transaction_of_listing(listing)
  transaction = Transaction.find_by_listing_id(listing.id)
  visit(person_transaction_path(:person_id => @current_user.id, :id => transaction.id, :locale => "en"))
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

Then /^I should see "(.*?)" in the message list$/ do |msg|
  expect(page.find("#messages")).to have_content(msg)
end
