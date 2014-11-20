module AdminManageMembersSteps
  POSTING_ALLOWED_CHECKBOX_SELECTOR = ".admin-members-can-post-listings"
  IS_ADMIN_CHECKBOX_SELECTOR = ".admin-members-is-admin"
  REMOVE_USER_CHECKBOX_SELECTOR = ".admin-members-remove-user"

  def find_row_for_person(full_name)
    email_div = find(".admin-members-full-name", :text => "#{full_name}")
    email_row = email_div.first(:xpath, ".//..")
  end

  def find_posting_allowed_checkbox_for_person(full_name)
    find_row_for_person(full_name).find(POSTING_ALLOWED_CHECKBOX_SELECTOR)
  end

  def find_admin_checkbox_for_person(full_name)
    find_row_for_person(full_name).find(IS_ADMIN_CHECKBOX_SELECTOR)
  end

  def find_remove_link_for_person(full_name)
    find_row_for_person(full_name).find(REMOVE_USER_CHECKBOX_SELECTOR)
  end

end

World(AdminManageMembersSteps)

Then(/^I should see a range from (\d+) to (\d+) with total user count of (\d+)$/) do |range_start, range_end, total_count|
  steps %Q{
    Then I should see "Displaying users #{range_start} - #{range_end} of #{total_count} in total" within "#admin_members_count"
  }
end

Then(/^I should see list of users with the following details:$/) do |table|
  
  # This waits for ajax requests to complete
  expect(page).to have_selector("#admin_members_list tbody tr", :count => table.rows.count)
  
  cells = all("#admin_members_list tbody tr").map do |rows|
    rows.all("td")
  end

  table.rows.each_with_index do |row, row_num|
    row.each_with_index do |cell, column_num|
      cell.should == cells[row_num][column_num].text
    end
  end
end

Then(/^I should see (\d+) users$/) do |user_count|
  expect(page).to have_selector("#admin_members_list tbody tr", :count => user_count)
end

Then(/^the first user should be "(.*?)"$/) do |full_name|
  first_row = all("#admin_members_list tbody tr").first
  first_row.all("td").first.text.should == full_name
end

Given(/^only verified users can post listings in this community$/) do
  @current_community.update_attribute(:require_verification_to_post_listings, true)
end

Then(/^I should see that "(.*?)" cannot post new listings$/) do |full_name|
  checkbox = find_posting_allowed_checkbox_for_person(full_name)
  checkbox['checked'].should be_nil
end

When(/^I verify user "(.*?)" as a seller$/) do |full_name|
  find_posting_allowed_checkbox_for_person(full_name).click
  steps %Q{
    Then I should see "Saved" within ".ajax-update-notification"
  }
end

Then(/^I should see that "(.*?)" can post new listings$/) do |full_name|
  find_posting_allowed_checkbox_for_person(full_name)['checked'].should_not be_nil
end

When(/^I remove user "(.*?)"$/) do |full_name|
  find_remove_link_for_person(full_name).click
  steps %Q{
    And I confirm alert popup
  }
end

Then(/^"(.*?)" should be banned from this community$/) do |username|
  person = Person.find_by_username(username)
  CommunityMembership.find_by_person_id_and_community_id(person.id, @current_community.id).status.should == "banned"
end

Given(/^user "(.*?)" is banned in this community$/) do |username|
  CommunityMembership.find_by_person_id_and_community_id(Person.find_by_username(username).id, @current_community.id).update_attribute(:status, "banned")
end

Then(/^I should see a message that I have been banned$/) do
  steps %Q{
    Then I should see "The administrator has prevented you from accessing"
  }
end

Then(/^I should be able to send a message to admin$/) do
  steps %Q{
    When I fill in "What would you like to tell us?" with "I sad that I have been banned."
    And I press "Send feedback"
    Then I should see "Thanks a lot for your feedback!" within ".flash-notifications"
  }
end

Then(/^I should see that "(.*?)" has admin rights in this community$/) do |full_name|
  find_admin_checkbox_for_person(full_name)['checked'].should_not be_nil
end

Then(/^I should see that "(.*?)" does not have admin rights in this community$/) do |full_name|
  find_admin_checkbox_for_person(full_name)['checked'].should be_nil
end

When(/^I promote "(.*?)" to admin$/) do |full_name|
  find_admin_checkbox_for_person(full_name).click
  steps %Q{
    Then I should see "Saved" within ".ajax-update-notification"
  }
end

Then(/^I should see that I can not remove admin rights of "(.*?)"$/) do |full_name|
  find_admin_checkbox_for_person(full_name)['disabled'].should be_truthy
end

Then(/^I should see that I can remove admin rights of "(.*?)"$/) do |full_name|
  find_admin_checkbox_for_person(full_name)['disabled'].should be_falsey
end
