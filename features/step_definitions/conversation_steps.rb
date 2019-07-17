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
    payment_process: TransactionProcess.find(listing.transaction_process_id).process,
    automatic_confirmation_after_days: community.automatic_confirmation_after_days
  )
end

Given /^there is a message "([^"]*)" from "([^"]*)" about that listing$/ do |message, sender|
  @transaction = create_transaction(@current_community, @listing, @people[sender], message)
  @conversation = @transaction.conversation
  TransactionService::StateMachine.transition_to(@transaction.id, "free")
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

def visit_transaction_of_listing(listing)
  transaction = Transaction.find_by_listing_id(listing.id)
  visit(person_transaction_path(:person_id => @current_user.id, :id => transaction.id, :locale => "en"))
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

Then(/^I should see price box on top of the message list$/) do
  visit_transaction_of_listing(@listing)
  expect(page).to have_css('.initiate-transaction-totals')
end

Then(/^I should not see price box on top of the message list$/) do
  visit_transaction_of_listing(@listing)
  expect(page).to have_no_css('.initiate-transaction-totals')
end

def create_paid_transaction(community, listing, starter, message, payment_gateway = :none, state = :not_started, buyer_commission = false )
  process = TransactionProcess.find(listing.transaction_process_id).process
  settings = PaymentSettings.where(active: true, community_id: community.id, payment_gateway: payment_gateway, payment_process: process).first
  booking = listing.availability == 'booking'
  tx_attributes = {
    listing: listing,
    community: community,
    starter: starter,
    conversation: build_conversation(community, listing, starter, message),
    payment_gateway: payment_gateway,
    payment_process: process,
    automatic_confirmation_after_days: community.automatic_confirmation_after_days,
    current_state: state,
    last_transition_at: Time.current,
    commission_from_seller: settings.commission_from_seller,
    minimum_commission_cents: 100,
    minimum_commission_currency: 'EUR'
  }
  if booking
    tx_attributes.merge!(
      listing_quantity: 3,
      unit_type: "hour",
      unit_price_cents: listing.price.cents,
      unit_price_currency: listing.price.currency)
  end
  if buyer_commission
    tx_attributes.merge!(
      commission_from_buyer: 15,
      minimum_buyer_fee_cents: 100,
      minimum_buyer_fee_currency: listing.price.currency)
  end
  tx = FactoryGirl.create(:transaction, tx_attributes)
  if booking
    FactoryGirl.create(:booking, tx: tx, start_on: nil, end_on: nil,
                                 start_time: "2019-01-02 09:00:00",
                                 end_time: "2019-01-02 12:00:00",
                                 per_hour: true)
  end
  FactoryGirl.create(:transaction_transition, tx: tx, to_state: state)
  tx
end

Given(/^there is a "([^"]*)" transaction from "([^"]*)" with message "([^"]*)" about that listing$/)do |state, sender, message|
  create_paid_transaction(@current_community, @listing, @people[sender], message, 'stripe', state)
end

Then(/^I visit transaction page of that listing$/) do
  visit_transaction_of_listing(@listing)
end

Given(/^there is a "([^"]*)" transaction with buyer commission from "([^"]*)" with message "([^"]*)" about that listing$/)do |state, sender, message|
  create_paid_transaction(@current_community, @listing, @people[sender], message, 'stripe', state, true)
end

Given(/free conversations are (disabled|enabled)/) do |state|
  @current_community.update(allow_free_conversations: state == 'enabled')
end
