Then /^"(.*?)" should have required Checkout payment details saved to my account information$/ do |username|
  p = Person.find_by_username(username)

  p.checkout_merchant_id.should_not be_nil
  p.checkout_merchant_id.should_not be_blank
  p.checkout_merchant_key.should_not be_nil
  p.checkout_merchant_key.should_not be_blank
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