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
    person = Person.find_by_username(hash[:person])
    community = Community.find_by_domain(hash[:community])
    attributes_to_update = hash.except('person', 'community')
    @account = create_braintree_account(person, community, attributes_to_update)
  end
end

Given(/^"(.*?)" has an (active) Braintree account$/) do |username, status|
  person = Person.find_by_username(username)
  @account = create_braintree_account(person, @current_community)
end

Given /^there is a payment for that request from "(.*?)" with price "(.*?)"$/ do |payer_username, price|
  listing = @conversation.listing
  payer = Person.find_by_username(payer_username)
  @payment = FactoryGirl.create(:braintree_payment, payer: payer, recipient: listing.author, community: @current_community, sum_cents: price.to_i * 100, conversation: @conversation)
end

Given /^that payment is (pending|paid)$/ do |status|
  @conversation.payment.update_attribute(:status, status)
end

Given(/^"(.*?)" has paid for that listing$/) do |username|
  conversation = @listing.conversations.find { |c| c.requester.username == username }
  conversation.status = "paid"
  conversation.save!
end

Then /^"(.*?)" should have required Checkout payment details saved to my account information$/ do |username|
  p = Person.find_by_username(username)

  p.checkout_merchant_id.should_not be_nil
  p.checkout_merchant_id.should_not be_blank
  p.checkout_merchant_key.should_not be_nil
  p.checkout_merchant_key.should_not be_blank
end

When /^Braintree webhook "(.*?)" with id "(.*?)" is triggered$/ do |kind, id|
  community = Community.find_by_name("test") # Hard-coded default test community
  signature, payload = BraintreeApi.webhook_testing_sample_notification(
    community, kind, id
  )

  # Do
  post "#{Capybara.app_host}/webhooks/braintree", :bt_signature => signature, :bt_payload => payload, :community_id => community.id
end

Given /^Braintree transaction is mocked$/ do
  BraintreeApi.should_receive(:transaction_sale)
    .and_return(Braintree::SuccessfulResult.new({:transaction => HashClass.new({:id => "123abc"})}))
end

Given /^Braintree submit to settlement is mocked$/ do
  BraintreeApi.should_receive(:submit_to_settlement)
    .and_return(Braintree::SuccessfulResult.new({:transaction => HashClass.new({:id => "123abc"})}))
end

Given /^Braintree escrow release is mocked$/ do
  BraintreeService.should_receive(:release_from_escrow).at_least(1).times.and_return(true)
end

Given /^Braintree merchant creation is mocked$/ do
  BraintreeApi.should_receive(:create_merchant_account) do |braintree_account, community|
    braintree_account.first_name.should == "Joe"
    braintree_account.last_name.should == "Bloggs"
    braintree_account.email.should == "joe@14ladders.com"
    braintree_account.phone.should == "5551112222"
    braintree_account.address_street_address.should == "123 Credibility St."
    braintree_account.address_postal_code.should == "60606"
    braintree_account.address_locality.should == "Chicago"
    braintree_account.address_region.should == "IL"
    braintree_account.date_of_birth.year.should == 1980
    braintree_account.date_of_birth.month.should == 10
    braintree_account.date_of_birth.day.should == 9
    braintree_account.routing_number.should == "101000187"
    braintree_account.account_number.should == "43759348798"
    braintree_account.person_id.should == "123abc"
    community.name('en').should == "test"
  end.and_return(Braintree::SuccessfulResult.new({:merchant_account => HashClass.new({:id => "123abc", :status => "pending"})}))
end

Given /^Braintree merchant creation is mocked to return failure$/ do
  BraintreeApi.should_receive(:create_merchant_account)
    .and_return(Braintree::ErrorResult.new(nil, :errors => { :errors => [] } ))
end

Given /^I want to pay "(.*?)"$/ do |item_title|
  # This probably fails if there are many payments waiting
  steps %Q{
    Given I am on the messages page
    Then I should see "Waiting for you to pay"
    When I click ".conversation-title-link"
    And I follow "Pay"
    Then I should see payment details form for Braintree
  }
end

When /^I cancel the transaction$/ do
  # This probably fails if there are many payments waiting
  steps %Q{
    Given I am on the messages page
    Then I should see "Waiting for you to mark the request completed"
    When I click ".conversation-title-link"
    And I follow "Did not happen"
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

When /^I browse to Checkout payment settings$/ do
  steps %Q{
    When I browse to payment settings
    Then I should be on the payment settings page
  }
end

Then /^the link to payment settings should be visible$/ do
  find("#settings-tab-payments").should be_visible
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
    When I fill in "person[company_id]" with "1234567-8"
    And I fill in "person[organization_address]" with "Startup Sauna, Betonimiehenkuja, Espoo, Finland"
    And I fill in "person[phone_number]" with "555-12345678"
    And I fill in "person[organization_website]" with "http://www.company.com/"
    And I press submit
  }
end

When /^I fill the payment details form with invalid information$/ do
  steps %Q{
    When I fill in "person[company_id]" with "12345465467484578"
    And I fill in "person[organization_address]" with ""
    And I fill in "person[phone_number]" with "555"
    And I fill in "person[organization_website]" with ""
    And I press submit
  }
end

Given /^"(.*?)" has Checkout account$/ do |org_username|
  org = Person.find_by_username(org_username)
  org.checkout_merchant_key = "SAIPPUAKAUPPIAS"
  org.checkout_merchant_id = "375917"
  org.save!
end

Given /^"(.*?)" does not have Checkout account$/ do |org_username|
  org = Person.find_by_username(org_username)
  org.checkout_merchant_key = nil
  org.checkout_merchant_id = nil
  org.save!
end

Then /^I should see information about existing Checkout account$/ do
  find("#payment-help-checkout-exists").visible?.should be_true
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

Then /^I should see that I successfully paid (\d+)$/ do |amount|
  steps %Q{
    Then I should see "paid"
    Then I should see "#{amount}"
  }
end

Then /^"(.*?)" should receive email about payment$/ do |receiver|
  email = Person.find_by_username(receiver).confirmed_notification_emails.first.address
  steps %Q{
    When the system processes jobs
  }
  # Sending email is not implemented for Braintree
  # steps %Q{
  #   Then "#{email}" should receive an email
  # }
end

Then /^I should not see payment setting fields$/ do
  page.should have_no_selector("#person-company-id")
  page.should have_no_selector("#person-organization-address")
  page.should have_no_selector("#person-phone-number")
  page.should have_no_selector("#person-organization-website")
  page.should have_no_selector("[type=submit]")
end

When /^I click Osuuspankki logo$/ do
  page.find('input[src="https://payment.checkout.fi/static/img/osuuspankki.png"]').click
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
