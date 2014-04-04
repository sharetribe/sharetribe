Given(/^community "(.*?)" has default browse view "(.*?)"$/) do |community, browse_view|
  Community.find_by_domain(community).update_attributes(default_browse_view: browse_view)
end

When(/^I change the default browse view to "(.*?)"$/) do |browse_view|
  steps %Q{
    When I select "#{browse_view}" from "community_default_browse_view"
    And I press submit
  }
end

Then(/^I should see the browse view selected as "(.*?)"$/) do |browse_view|
  find(".home-toolbar-button-group .selected").should have_content(browse_view)
end

Given(/^community "(.*?)" has name display type "(.*?)"$/) do |community, name_display_type|
  Community.find_by_domain(community).update_attributes(name_display_type: name_display_type)
end

When(/^I change the name display type to "(.*?)"$/) do |name_display_type|
  steps %Q{
    When I select "#{name_display_type}" from "community_name_display_type"
    And I press submit
  }
end

Then(/^I should see my name displayed as "(.*?)"$/) do |name|
  find(".user-name").should have_content(name)
end

