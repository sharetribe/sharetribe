Given /^community "(.*?)" allows only organizations$/ do |community|
  c = Community.find_by_domain(community)
  c.only_organizations = true
  c.save!
end

Given /^I signup as an organization "(.*?)" with name "(.*?)"$/ do |org_username, org_display_name|
  steps %Q{
    Given I am on the signup page
    When I fill in "person[username]" with "#{org_username}"
    And I fill in "person[organization_name]" with "#{org_display_name}"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person[terms]"
    And I press "Create account"
  }
end

When /^I confirm my email address$/ do
  steps %Q{
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "The email you entered is now confirmed"
  }
end

When /^I confirm email address "(.*?)"$/ do |email|
  steps %Q{
    Then "#{email}" should receive 1 email
    When "#{email}" open the email
    And I click the first link in the email
    Then "#{email}" should have 2 emails
    And I should see "The email you entered is now confirmed"
  }
end

Then /^"(.*?)" should have required Checkout payment details saved to my account information$/ do |username|
  p = Person.find_by_username(username)

  p.checkout_merchant_id.should_not be_nil
  p.checkout_merchant_id.should_not be_blank
  p.checkout_merchant_key.should_not be_nil
  p.checkout_merchant_key.should_not be_blank
end

Then /^there should be an organization account "(.*?)"$/ do |org_username|
  o = Person.find_by_username(org_username)
  o.is_organization.should be_true
  o.confirmed_at.should_not be_nil
end

Then /^I should see "(.*?)" as logged in user$/ do |display_name|
  steps %Q{
    Then I should see "#{display_name}" within ".user-name"
  }
end

When /^I browse to payment settings$/ do
  steps %Q{
    When I go to the settings page
    Then the link to payment settings should be visible
    When I follow link to payment settings
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

Then /^I should see flash error$/ do
  find(".flash-error").should be_visible
end

Then /^I should see validation error$/ do
  find("[generated='true'].error").should be_visible
end

Given /^there is an organization "(.*?)"$/ do |org_username|
  FactoryGirl.create(:person, :username => org_username, :is_organization => true)
end

Given /^"(.*?)" is not an organization$/ do |username|
  user = Person.find_by_username(username)
  user.is_organization = false
  user.save!
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

Then /^I should not see payment setting fields$/ do
  page.should have_no_selector("#person-company-id")
  page.should have_no_selector("#person-organization-address")
  page.should have_no_selector("#person-phone-number")
  page.should have_no_selector("#person-organization-website")
  page.should have_no_selector("[type=submit]")
end

Given /^there is a (seller|non\-seller) organization "(.*?)"(?: with email requirement "(.*?)")?$/ do |seller_status, name, allowed_emails|
  org_params = {:name => name, :allowed_emails => allowed_emails}
  
  if seller_status == "non-seller"
    org_params.merge!({:merchant_id => nil, :merchant_key => nil})
  end
  FactoryGirl.create(:organization, org_params)
end

Given /^"(.*?)" is an admin of the organization "(.*?)"$/ do |person_name, org_name|
  org = Organization.find_by_name!(org_name)
  person = Person.find_by_username!(person_name)
  m = OrganizationMembership.find_or_create_by_person_id_and_organization_id(person.id, org.id)
  m.update_attribute(:admin, true)
end

Then /^Most recently created organization should have all seller attributes filled$/ do
  o = Organization.last
  o.name.should_not be_blank
  o.company_id.should_not be_blank
  o.merchant_id.should_not be_blank
  o.merchant_key.should_not be_blank
end

When /^I click Osuuspankki logo$/ do
  page.find('input[src="https://payment.checkout.fi/static/img/osuuspankki.png"]').click
end

When /^I click Tilisiirto logo$/ do
  page.find('input[src="https://payment.checkout.fi/static/img/tilisiirto.gif"]').click
end


Then /^organization "(.*?)" should have a merchant_id$/ do |org_name|
  org = Organization.find_by_name!(org_name)
  org.merchant_id.should_not be_nil
end

Then /^I should receive an email about missing payment details$/ do
  steps %Q{
    Then I should receive an email with subject "Remember to add your payment details to receive payments"
    When I open the email
    And I should see "However, you haven't yet added your payment details. In order to receive the payment you have to add your payment information." in the email body
  }
end
