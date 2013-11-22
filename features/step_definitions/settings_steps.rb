When /^I add a new email "(.*?)"$/ do |email|
  steps %Q{
    When I click "#account-new-email"
    And I fill in "person_email_attributes_address" with "#{email}"
    And I wait for 1 seconds
    And I press "email_submit"
    Then I should see "#{email}"
  }
end

Then /^I should not be able to remove email$/ do
  
end