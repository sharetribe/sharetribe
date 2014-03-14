When(/^I add "(.*?)" to Twitter handle field$/) do |arg1|
  steps %Q{
    When I fill in "Twitter handle" with "#{arg1}"
  }
end

Then(/^I should see "(.*?)" in the Twitter handle field$/) do |arg1|
   steps %Q{
    Then I should see "#{arg1}" within "#community_twitter_handle"
  }
end