module AdminManageMembersSteps
  POSTING_ALLOWED_CHECKBOX_SELECTOR = ".admin-members-can-post-listings"

  def find_row_for_person(full_name)
    email_div = find(".admin-members-full-name", :text => "#{full_name}")
    email_row = email_div.first(:xpath, ".//..")
  end

  def find_posting_allowed_checkbox_for_person(full_name)
    find_row_for_person(full_name).find(POSTING_ALLOWED_CHECKBOX_SELECTOR)
  end

end

World(AdminManageMembersSteps)

Then(/^I should see a range from (\d+) to (\d+) with total user count of (\d+)$/) do |range_start, range_end, total_count|
  steps %Q{
    Then I should see "Displaying users #{range_start} - #{range_end} of #{total_count} in total" within "#admin_members_count"
  }
end

Then(/^I should see list of users with the following details:$/) do |table|
  # table is a Cucumber::Ast::Table
  all("#admin_members_list tbody tr").each_with_index do |row, i|
    row.all("td").each_with_index do |cell, j|
      table.rows[i][j].should== cell.text
    end
  end
end

Then(/^I should see (\d+) users$/) do |user_count|
  all("#admin_members_list tbody tr").count.should == user_count.to_i
end

Then(/^the first user should be "(.*?)"$/) do |full_name|
  first_row = all("#admin_members_list tbody tr").first
  first_row.all("td").first.text.should == full_name
end

Given(/^only verified users can post listings in this community$/) do
  @current_community.update_attribute(:require_verification_to_post_listings, true)
end

Then(/^I should see that "(.*?)" cannot post new listings$/) do |full_name|
  #binding.pry
  checkbox = find_posting_allowed_checkbox_for_person(full_name)
  checkbox['checked'].should be_nil
end

When(/^I verify user "(.*?)" as a seller$/) do |full_name|
  find_posting_allowed_checkbox_for_person(full_name).click
  steps %Q{
    Then there should be an active ajax request
    When ajax requests are completed
  }
end

Then(/^I should see that "(.*?)" can post new listings$/) do |full_name|
  find_posting_allowed_checkbox_for_person(full_name)['checked'].should_not be_nil
end

When(/^I remove user "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^"(.*?)" should be banned from this community$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

