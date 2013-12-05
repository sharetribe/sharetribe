When /^I click save on the editor$/ do
  find("em", :text => "Save").click
  # Wait for editor to close
  steps %Q{
    Then I should not have editor open
  }
end

Then /^I should not have editor open$/ do
  page.should have_no_selector("#mercury_iframe")
end

Then /^I should have editor open$/ do
  page.should have_selector("#mercury_iframe")
end

When(/^I send keys "(.*?)" to editor$/) do |keys|
  find("#mercury_iframe", :visible => false).native.send_keys "#{keys}"
end