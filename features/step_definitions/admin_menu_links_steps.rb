When(/^I remove menu link with title "(.*?)"$/) do |title|
  find_remove_link_for_menu_link(title).click
end

When(/^I click up for menu link "(.*?)"$/) do |title|
  find_up_link_for_menu_link(title).click
end