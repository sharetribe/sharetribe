When(/^I remove menu link with title "(.*?)"$/) do |title|
  find_remove_link_for_menu_link(title).click
end

When(/^I click up for menu link "(.*?)"$/) do |title|
  find_up_link_for_menu_link(title).click
end

When(/^I fill in menu link field "(.*?)" with locale "(.*?)" with "([^"]*)" count of symbols$/) do |field, locale, count_of_symbols|
  menu_link_id = @current_community.menu_links.first.id
  field_name = "menu_links[menu_link_attributes][#{menu_link_id}][translation_attributes][#{locale}][#{field}]"
  steps %{
    When I fill in "#{field_name}" with "#{count_of_symbols}" count of symbols
  }
end

Then(/^I should see "([^"]*)" count of symbols in the "([^"]*)" menu link field with locale "([^"]*)"$/) do |count_of_symbols, field, locale|
  menu_link_id = @current_community.menu_links.first.id
  field_name = "menu_links[menu_link_attributes][#{menu_link_id}][translation_attributes][#{locale}][#{field}]"
  steps %{
    Then I should see "#{count_of_symbols}" count of symbols in the "#{field_name}" input
  }
end
