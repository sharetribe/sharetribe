Then(/^I should see member count (\d+)$/) do |member_count|
  steps %Q{
    Then I should see "#{member_count}" within "#admin_members_count"
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

Given(/^only verified users can post listings in this community$/) do
  @current_community.update_attribute(:require_verification_to_post_listings, true)
end

When(/^I verify user "(.*?)" as a seller$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that "(.*?)" can post new listings$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end