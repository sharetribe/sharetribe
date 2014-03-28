Given(/^community "(.*?)" has default browse view "(.*?)"$/) do |community, browse_view|
  Community.find_by_domain(community).update_attributes(default_browse_view: browse_view)
end

When(/^I change the default browse view to "(.*?)"$/) do |browse_view|
  select browse_view, :from => "community_default_browse_view"

  steps %Q{
    And I press submit
  }
end

Then(/^I should see the browse view selected as "(.*?)"$/) do |browse_view|
  find(".home-toolbar-button-group .selected").should have_content(browse_view)
end

