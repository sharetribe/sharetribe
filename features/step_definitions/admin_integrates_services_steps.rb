When(/^I add "(.*?)" to the Twitter handle field$/) do |arg1|
  steps %Q{
    When I fill in "Twitter handle" with "#{arg1}"
  }
end

Then(/^I should see "(.*?)" in the Twitter handle field$/) do |arg1|
  find('#community_twitter_handle').value.should== arg1
end

When(/^I add "(.*?)" to the Google analytics key field$/) do |arg1|
  steps %Q{
    When I fill in "Google Analytics tracking ID (classic account)" with "#{arg1}"
  }
end

Then(/^I should see "(.*?)" in the Google analytics key field$/) do |arg1|
  find('#community_google_analytics_key').value.should== arg1
end
