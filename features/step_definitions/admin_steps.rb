When /^I remove the slogan$/ do
  steps %Q{
    When I fill in "community[slogan]" with ""
  }
end

Then /^I should see slogan "([^"]*)"$/ do |slogan|
  steps %Q{
    Then I should see "#{slogan}" within "#community-slogan"
  }
end

Then /^I should not see slogan$/ do
  steps %Q{
    Then the element "#community-slogan" should be empty
  }
end

When /^I remove the description$/ do
  steps %Q{
    When I fill in "community[description]" with ""
  }
end

Then /^I should see description "([^"]*)"$/ do |description|
  steps %Q{
    Then I should see "#{description}" within "#community-description"
  }
end

Then /^I should not see description$/ do
  steps %Q{
    Then the element "#community-description" should be empty
  }
end