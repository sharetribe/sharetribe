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

Then /^there should be an organization account "(.*?)"$/ do |org_username|
  o = Person.find_by_username(org_username)
  o.is_organization.should be_truthy
end

Then /^I should see flash error$/ do
  find(".flash-error").should be_visible
end

Given /^there is an organization "(.*?)"$/ do |org_username|
  FactoryGirl.create(:person, :username => org_username, :is_organization => true)
end

Given /^"(.*?)" is not an organization$/ do |username|
  user = Person.find_by_username(username)
  user.is_organization = false
  user.save!
end
