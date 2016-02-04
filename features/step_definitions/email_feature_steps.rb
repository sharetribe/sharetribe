# This file contains step definitions for features under folder email/
# The file naming is troublesome, since email_steps.rb was already reserved.

Given(/^I have received a weekly updates email$/) do
  create_listing(shape: all_shapes.first)
  CommunityMailer.deliver_community_updates
  expect(email_count).to eq(1)
end

Given(/^I click a link to unsubscribe$/) do
  open_email_for_current_user
  visit_in_email("unsubscribe")
end

Then(/^I should see that I have successfully unsubscribed$/) do
  expect(page).to have_content("Unsubscribe succesful")
end

Then(/^I should not receive weekly updates email anymore$/) do
  create_listing(shape: all_shapes.first)
  CommunityMailer.deliver_community_updates
  expect(email_count).to eq(1)
end
