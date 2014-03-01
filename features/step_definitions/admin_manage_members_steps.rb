Then(/^I should see a range from (\d+) to (\d+) with total user count of (\d+)$/) do |range_start, range_end, total_count|
  steps %Q{
    Then I should see "Displaying members #{range_start} - #{range_end} of #{total_count} in total" within "#admin_members_count"
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

When(/^I verify user "(.*?)" as a seller$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that "(.*?)" can post new listings$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
