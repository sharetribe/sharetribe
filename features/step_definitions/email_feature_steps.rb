# This file contains step definitions for features under folder email/
# The file naming is troublesome, since email_steps.rb was already reserved.

Given(/^I have received a weekly updates email$/) do
  create_listing_to_current_community()
  CommunityMailer.deliver_community_updates
  email_count.should == 1
end

Given(/^I click a link to unsubscribe$/) do
  open_email_for_current_user
  visit_in_email("unsubscribe")
end

Then(/^I should see that I have successfully unsubscribed$/) do
  page.should have_content("Unsubscribe succesful")
end

Then(/^I should not receive weekly updates email anymore$/) do
  create_listing_to_current_community()
  CommunityMailer.deliver_community_updates
  email_count.should == 1
end