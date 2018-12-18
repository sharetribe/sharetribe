module AdminManageMembersSteps
  POSTING_ALLOWED_CHECKBOX_SELECTOR = ".admin-members-can-post-listings"
  IS_ADMIN_CHECKBOX_SELECTOR = ".admin-members-is-admin"
  BAN_USER_CHECKBOX_SELECTOR = ".admin-members-ban-toggle"

  def find_row_for_person(full_name)
    expect(page).to have_css(".admin-members-full-name", :text => full_name)
    email_div = find(".admin-members-full-name", :text => full_name)
    email_row = email_div.first(:xpath, ".//..")
  end

  def find_element_for_person(full_name, selector)
    row = find_row_for_person(full_name)
    expect(row).to have_css(selector)
    row.find(selector)
  end

  def find_posting_allowed_checkbox_for_person(full_name)
    find_element_for_person(full_name, POSTING_ALLOWED_CHECKBOX_SELECTOR)
  end

  def find_admin_checkbox_for_person(full_name)
    find_element_for_person(full_name, IS_ADMIN_CHECKBOX_SELECTOR)
  end

  def find_ban_user_checkbox_for_person(full_name)
    find_element_for_person(full_name, BAN_USER_CHECKBOX_SELECTOR)
  end
end

World(AdminManageMembersSteps)

Then(/^I should see a range from (\d+) to (\d+) with total (\d+) accepted and (\d+) banned users$/) do |range_start, range_end, accepted_count, banned_count|
  steps %Q{
    Then I should see "Displaying users #{range_start} - #{range_end} of #{accepted_count} accepted users and #{banned_count} banned users" within "#admin_members_count"
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
      expect(cell).to eq(cells[row_num][column_num].text)
    end
  end
end

Then(/^I should see (\d+) users$/) do |user_count|
  expect(page).to have_selector("#admin_members_list tbody tr", :count => user_count)
end

Then(/^the first user should be "(.*?)"$/) do |full_name|
  first_row = all("#admin_members_list tbody tr").first
  expect(first_row.all("td").first.text).to eq(full_name)
end

Given(/^only verified users can post listings in this community$/) do
  @current_community.update_attribute(:require_verification_to_post_listings, true)
end

Then(/^I should see that "(.*?)" cannot post new listings$/) do |full_name|
  checkbox = find_posting_allowed_checkbox_for_person(full_name)
  expect(checkbox['checked']).to be_nil
end

When(/^I verify user "(.*?)" as a seller$/) do |full_name|
  find_posting_allowed_checkbox_for_person(full_name).click
  steps %Q{
    Then I should see "Saved" within ".ajax-update-notification"
  }
end

Then(/^I should see that "(.*?)" can post new listings$/) do |full_name|
  expect(find_posting_allowed_checkbox_for_person(full_name)['checked']).not_to be_nil
end

When(/^I (.*?)ban user "(.*?)"$/) do |unban_str, full_name|
  checkbox = find_ban_user_checkbox_for_person(full_name)

  do_unban = (unban_str == 'un')
  expect(checkbox.checked?).to eq(do_unban),
    "incorrect checkbox state for #{unban_str}ban"

  checkbox.click
  steps %Q{
    And I confirm alert popup
  }
end


Then(/^"(.*?)" should (.*?)be banned from this community$/) do |username, not_banned|
  not_banned = not_banned.include?('not')
  person = Person.find_by(username: username, community_id: @current_community.id)
  expect(CommunityMembership.find_by_person_id_and_community_id(person.id, @current_community.id).status).to eq((not_banned ? "accepted" : "banned"))
end

Given(/^user "(.*?)" is banned in this community$/) do |username|
  CommunityMembership.find_by(person_id: Person.find_by(username: username).id, community_id: @current_community.id).update_attribute(:status, "banned")
end

Then(/^I should see a message that I have been banned$/) do
  steps %Q{
    Then I should see "The team has prevented you from accessing"
  }
end

Then(/^I should be able to send a message to admin$/) do
  steps %Q{
    When I fill in "feedback_content" with "I sad that I have been banned."
    And I press "Send message"
    Then I should see "Thanks a lot for your message!" within ".flash-notifications"
  }
end

Then(/^I should see that "(.*?)" has admin rights in this community$/) do |full_name|
  expect(find_admin_checkbox_for_person(full_name)['checked']).not_to be_nil
end

Then(/^I should see that "(.*?)" does not have admin rights in this community$/) do |full_name|
  expect(find_admin_checkbox_for_person(full_name)['checked']).to be_nil
end

When(/^I promote "(.*?)" to admin$/) do |full_name|
  find_admin_checkbox_for_person(full_name).click
  steps %Q{
    Then I should see "Saved" within ".ajax-update-notification"
  }
end

Then(/^I should see that I can not remove admin rights of "(.*?)"$/) do |full_name|
  expect(find_admin_checkbox_for_person(full_name)['disabled']).to be_truthy
end

Then(/^I should see that I can remove admin rights of "(.*?)"$/) do |full_name|
  expect(find_admin_checkbox_for_person(full_name)['disabled']).to be_falsey
end
