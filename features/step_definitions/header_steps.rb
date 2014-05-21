module HeaderSteps
  REMOVE_SELECTOR    = ".menu-link-remove"
  UP_SELECTOR        = ".menu-link-action-up"
  MENU_ROW_CLASS     = "menu-link-container"

  def find_row_for_menu_link(title)
    find(:xpath, "//div[contains(@class, '#{MENU_ROW_CLASS}')][descendant::input[@value='#{title}']]")
  end

  def find_remove_link_for_menu_link(title)
    find_row_for_menu_link(title).find(REMOVE_SELECTOR)
  end

  def find_up_link_for_menu_link(title)
    find_row_for_menu_link(title).find(UP_SELECTOR)
  end
end
World(HeaderSteps)

When(/^I click the community logo$/) do
  find("#header-logo").click
end

When(/^I open language menu$/) do
  find("#header-locales-menu").click
end

Then(/^I should (not see|see) "(.*)" on the menu$/) do |action, language|
  steps %Q{
    Then I should #{action} "#{language}" within "#header-menu-toggle-menu"
  }
end

Then(/^I should see "(.*)" on the language menu$/) do |language|
  steps %Q{
    Then I should see "#{language}" within "#header-locales-toggle-menu"
  }
end

When(/^I select "(.*)" from the language menu$/) do |language|
  steps %Q{
    When I follow "#{language}" within "#header-locales-toggle-menu"
  }
end

When(/^I open the menu$/) do
  find("#header-menu-desktop-anchor").click
end

When(/^I open user menu$/) do
  find("#header-user-desktop-anchor").click
end

When(/^I follow "(.*)" within the menu$/) do |label|
  steps %Q{
    When I follow "#{label}" within "#header-menu-toggle-menu"
  }
end

When(/^I follow inbox link$/) do
  steps %Q{
    When I follow "inbox-link"
  }
end

Then(/^I should see that there (?:is|are) (\d+|no) new messages?$/) do |message_count|
  message_count = "" if message_count == "no"
  steps %Q{
    Then I should see "#{message_count}" within "#inbox-link"
  }
end

Then /^I should see "(.*?)" as logged in user$/ do |display_name|
  steps %Q{
    Then I should see my name displayed as "#{display_name}"
  }
end

Then(/^I should see my name displayed as "(.*?)"$/) do |name|
  find("#header-user-display-name").should have_content(name)
end

When(/^I log out$/) do
  steps %Q{
    When I open user menu
  }
  click_link "Log out"
end

When(/^I navigate to invitations page$/) do
  steps %Q{
    When I open the menu
    And I follow "Invite" within the menu
  }
end

When(/^I follow log in link$/) do
  steps %Q{
    When I follow "header-login-link"
  }
end

Then(/^I should be logged in$/) do
  if page.respond_to? :should
    page.should have_no_css("#header-login-link")
  else
    assert page.has_no_css?("#header-login-link")
  end
end

Then(/^I should not be logged in$/) do
  if page.respond_to? :should
    page.should have_css("#header-login-link")
  else
    assert page.has_css?("#header-login-link")
  end
end

Given(/^there is a menu link "(.*?)" to "(.*?)"$/) do |title, url|
  link = FactoryGirl.build(:menu_link, community: @current_community)
  link.translations << FactoryGirl.build(:menu_link_translation, title: title, url: url, menu_link: link)
  link.save!
  @current_community.menu_links << link
end

Given(/^there is a menu link$/) do
  @menu_link = FactoryGirl.create(:menu_link, community: @current_community)
  @current_community.menu_links << @menu_link
end

Given(/^the title is "(.*?)" and the URL is "(.*?)" with locale "(.*?)" for that menu link$/) do |title, url, locale|
  @menu_link.translations << FactoryGirl.create(:menu_link_translation, title: title, url: url, locale: locale)
end

When(/^I remove menu link with title "(.*?)"$/) do |title|
  find_remove_link_for_menu_link(title).click
end

When(/^I click up for menu link "(.*?)"$/) do |title|
  find_up_link_for_menu_link(title).click
end