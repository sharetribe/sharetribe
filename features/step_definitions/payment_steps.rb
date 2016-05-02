require 'cucumber/rspec/doubles'

CC_NAME = "[name='braintree_payment[cardholder_name]']"
CC_NUMBER = "[name='braintree_payment[credit_card_number]']"
CC_CVV = "[name='braintree_payment[cvv]']"

module PaymentSteps

  def create_braintree_account(person, community, opts={})
    account = FactoryGirl.create(:braintree_account, :person => person, :community => community)
    account.update_attributes(opts) unless opts.empty?
    account
  end

end

World(PaymentSteps)

Given /^there are following Braintree accounts:$/ do |bt_accounts|
  # Create new accounts
  bt_accounts.hashes.each do |hash|
    community = Community.find_by(ident: hash[:community])
    person = Person.find_by(username: hash[:person], community_id: community.id)
    attributes_to_update = hash.except('person', 'community')
    @account = create_braintree_account(person, community, attributes_to_update)
  end
end

Given(/^"(.*?)" has an? (active) Braintree account$/) do |username, status|
  person = Person.find_by!(username: username, community_id: @current_community.id)
  @account = create_braintree_account(person, @current_community)
end

Given /^there is a payment for that request from "(.*?)" with price "(.*?)"$/ do |payer_username, price|
  listing = @transaction.listing
  payer = Person.find_by(username: payer_username, community_id: @current_community.id)
  @payment = FactoryGirl.create(:braintree_payment, payer: payer, recipient: listing.author, community: @current_community, sum_cents: price.to_i * 100, tx: @transaction)
end

Given /^that payment is (pending|paid)$/ do |status|
  @transaction.payment.update_attribute(:status, status)
end

Given(/^"(.*?)" has paid for that listing$/) do |username|
  transaction = Transaction.find_by_listing_id(@listing)
  MarketplaceService::Transaction::Command.transition_to(transaction.id, "paid")
end

Then /^"(.*?)" should have required Checkout payment details saved to my account information$/ do |username|
  p = Person.find_by(username: username, community_id: @current_community.id)
  expect(p.checkout_account.merchant_id).not_to be_nil
  expect(p.checkout_account.merchant_id).not_to be_blank
  expect(p.checkout_account.merchant_key).not_to be_nil
  expect(p.checkout_account.merchant_key).not_to be_blank
end

When /^Braintree webhook "(.*?)" with id "(.*?)" is triggered$/ do |kind, id|
  community = Community.where(ident: "test").first # Hard-coded default test community
  signature, payload = BraintreeApi.webhook_testing_sample_notification(
    community, kind, id
  )

  # Do
  post "#{Capybara.app_host}/webhooks/braintree", :bt_signature => signature, :bt_payload => payload, :community_id => community.id
end

When /^Braintree webhook "(.*?)" with username "(.*?)" is triggered$/ do |kind, username|
  community = Community.find_by(ident: "test") # Hard-coded default test community
  person = Person.find_by(username: username, community_id: community.id)
  signature, payload = BraintreeApi.webhook_testing_sample_notification(
    community, kind, person.id
  )

  # Do
  post "#{Capybara.app_host}/webhooks/braintree", :bt_signature => signature, :bt_payload => payload, :community_id => community.id
end

Given /^Braintree transaction is mocked$/ do
  expect(BraintreeApi).to receive(:transaction_sale) do |community, params|
    cc = params[:credit_card]
    # Check that the value is encrypted
    expect(cc[:number]).to start_with("$bt4|javascript_1_3_10$")
    expect(cc[:expiration_month]).to start_with("$bt4|javascript_1_3_10$")
    expect(cc[:expiration_year]).to start_with("$bt4|javascript_1_3_10$")
    expect(cc[:cvv]).to start_with("$bt4|javascript_1_3_10$")
    expect(cc[:cardholder_name]).to start_with("$bt4|javascript_1_3_10$")
  end.and_return(Braintree::SuccessfulResult.new({:transaction => HashClass.new({:id => "123abc"})}))
end

Given /^Braintree submit to settlement is mocked$/ do
  expect(BraintreeApi).to receive(:submit_to_settlement)
    .and_return(Braintree::SuccessfulResult.new({:transaction => HashClass.new({:id => "123abc"})}))
end

Given /^Braintree escrow release is mocked$/ do
  expect(BraintreeService::EscrowReleaseHelper).to receive(:release_from_escrow).at_least(1).times.and_return(true)
end

Given /^Braintree void transaction is mocked$/ do
  expect(BraintreeApi).to receive(:void_transaction).at_least(1).times
    .and_return(Braintree::SuccessfulResult.new({:transaction => HashClass.new({:id => "123abc"})}))
end

Given /^Braintree merchant creation is mocked$/ do
  expect(BraintreeApi).to receive(:create_merchant_account) do |braintree_account, community|
    expect(braintree_account.first_name).to eq("Joe")
    expect(braintree_account.last_name).to eq("Bloggs")
    expect(braintree_account.email).to eq("joe@14ladders.com")
    expect(braintree_account.phone).to eq("5551112222")
    expect(braintree_account.address_street_address).to eq("123 Credibility St.")
    expect(braintree_account.address_postal_code).to eq("60606")
    expect(braintree_account.address_locality).to eq("Chicago")
    expect(braintree_account.address_region).to eq("IL")
    expect(braintree_account.date_of_birth.year).to eq(1980)
    expect(braintree_account.date_of_birth.month).to eq(10)
    expect(braintree_account.date_of_birth.day).to eq(9)
    expect(braintree_account.routing_number).to eq("101000187")
    expect(braintree_account.account_number).to eq("43759348798")
    expect(braintree_account.person_id).to eq(@current_user.id)
    expect(community.name('en')).to eq("Sharetribe")
  end.and_return(Braintree::SuccessfulResult.new({:merchant_account => HashClass.new({:id => @current_user.id, :status => "pending"})}))
end

Given /^Braintree merchant creation is mocked to return failure$/ do
  expect(BraintreeApi).to receive(:create_merchant_account)
    .and_return(Braintree::ErrorResult.new(nil, :errors => { :errors => [] } ))
end

Given /^I want to pay "(.*?)"$/ do |item_title|
  # This probably fails if there are many payments waiting
  steps %Q{
    Given I am on the messages page
    Then I should see "Waiting for you to pay"
    When I click ".conversation-title-link-unread"
    And I follow "Pay"
    Then I should see payment details form for Braintree
  }
end

When /^I cancel the transaction$/ do
  # This probably fails if there are many payments waiting
  steps %Q{
    Given I am on the messages page
    Then I should see "Waiting for you to mark the order completed"
    When I click ".conversation-title-link-unread"
    And I follow "Dispute"
  }
end

Then /^I should see payment details form for Braintree$/ do
  steps %Q{
    Then I should see selector "#{CC_NAME}"
    Then I should see selector "#{CC_NUMBER}"
  }
end

When /^I fill in my payment details for Braintree$/ do
  find("#{CC_NAME}").set("Joe Bloggs")
  find("#{CC_NUMBER}").set("5105105105105100")
  find("#{CC_CVV}").set("123")
  steps %Q{
    And I press submit
  }
end

When /^I browse to payment settings$/ do
  steps %Q{
    When I go to the settings page
    Then the link to payment settings should be visible
    When I follow link to payment settings
  }
end

When /^I browse to Checkout account settings$/ do
  steps %Q{
    When I browse to payment settings
    Then I should be on the new Checkout account page
  }
end

Then /^the link to payment settings should be visible$/ do
  expect(find("#settings-tab-payments")).to be_visible
end

When /^I follow link to payment settings$/ do
  steps %Q{
    When I follow "settings-tab-payments"
  }
end

When /^I fill in Braintree account details$/ do
  steps %Q{
    When I fill in "braintree_account[first_name]" with "Joe"
    And I fill in "braintree_account[last_name]" with "Bloggs"
    And I fill in "braintree_account[email]" with "joe@14ladders.com"
    And I fill in "braintree_account[phone]" with "5551112222"
    And I fill in "braintree_account[address_street_address]" with "123 Credibility St."
    And I fill in "braintree_account[address_postal_code]" with "60606"
    And I fill in "braintree_account[address_locality]" with "Chicago"
    And I select "Illinois" from "braintree_account[address_region]"
    And I select "1980" from "braintree_account[date_of_birth(1i)]"
    And I select "October" from "braintree_account[date_of_birth(2i)]"
    And I select "9" from "braintree_account[date_of_birth(3i)]"
    And I fill in "braintree_account[routing_number]" with "101000187"
    And I fill in "braintree_account[account_number]" with "43759348798"
  }
end

When /^I fill the payment details form(?: with valid information)?$/ do
  steps %Q{
    When I fill in "checkout_account_form[company_id_or_personal_id]" with "1234567-8"
    And I fill in "checkout_account_form[organization_address]" with "Startup Sauna, Betonimiehenkuja, Espoo, Finland"
    And I fill in "checkout_account_form[phone_number]" with "555-12345678"
    And I fill in "checkout_account_form[organization_website]" with "http://www.company.com/"
    And I press submit
  }
end

When /^I fill the payment details form with invalid information$/ do
  steps %Q{
    When I fill in "checkout_account_form[company_id_or_personal_id]" with "12345465467"
    And I fill in "checkout_account_form[organization_address]" with "kepponen"
    And I fill in "checkout_account_form[phone_number]" with "555"
    And I fill in "checkout_account_form[organization_website]" with ""
    And I press submit
  }
end

Given /^"(.*?)" has Checkout account$/ do |org_username|
  org = Person.find_by(username: org_username)
  checkout = CheckoutAccount.new({ merchant_key: "SAIPPUAKAUPPIAS", merchant_id: "375917", person_id: org.id })
  checkout.save!
end

Given /^"(.*?)" does not have Checkout account$/ do |org_username|
  org = Person.find_by(username: org_username)
  org.checkout_account.destroy if org.checkout_account.present?
end

Then /^I should see information about existing Checkout account$/ do
  expect(find("#payment-help-checkout-exists").visible?).to be_truthy
  steps %Q{
    And I should not see payment setting fields
  }
end

Then /^I should be see that the payment was successful$/ do
  steps %Q{
    Then I should see "paid"
    Then I should see "101"
  }
end

Then /^I should see that I successfully paid (.*?)$/ do |amount|
  expect(page).to have_content("paid #{amount}")
end

Then /^I should see that I successfully authorized payment (.*?)$/ do |amount|
  expect(page).to have_content("Payment authorized: #{amount}")
end

Then /^"(.*?)" should receive email about payment$/ do |receiver|
  email = Person.find_by(username: receiver).confirmed_notification_emails.first.address
  steps %Q{
    When the system processes jobs
  }
  # Sending email is not implemented for Braintree
  # steps %Q{
  #   Then "#{email}" should receive an email
  # }
end

Then /^I should not see payment setting fields$/ do
  expect(page).to have_no_selector("#person-company-id")
  expect(page).to have_no_selector("#person-organization-address")
  expect(page).to have_no_selector("#person-phone-number")
  expect(page).to have_no_selector("#person-organization-website")
  expect(page).to have_no_selector("[type=submit]")
end

When /^I click Tilisiirto logo$/ do
  page.find('input[src="https://payment.checkout.fi/static/img/tilisiirto.gif"]').click
end

Then /^I should receive an email about missing payment details$/ do
  steps %Q{
    Then I should receive an email with subject "Remember to add your payment details to receive payments"
    When I open the email
    And I should see "However, you haven't yet added your payment details. In order to receive the payment you have to add your payment information." in the email body
  }
end

Then /^I should see receipt info for unit_type (.*?) with quantity (\d+) and subtotal of (.*?)$/ do |unit_type, quantity, subtotal|
  expect(page).to have_content("Price per #{unit_type}")
  expect(page).to have_content("Subtotal:")
  expect(page).to have_content("Total:")

  expect(find(".initiate-transaction-quantity-value")).to have_content(quantity)
  expect(find(".initiate-transaction-sum-value")).to have_content(subtotal)
end

