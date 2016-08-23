module AdminLookAndFeelSteps

  # "#FF0044" -> [255, 0, 68]
  def hexToRgb(hex)
    hex.split("#").last.scan(/../).map { |s| s.to_i(16) }
  end
end

World(AdminLookAndFeelSteps)

When(/^I set the new listing button color to "(.*?)"$/) do |color|
  steps %Q{ And I fill in "community[custom_color2]" with "#{color}" }
end

Then(/^I should see that the background color of Post a new listing button is "(.*?)"$/) do |color|
  expected_color = "rgb(#{hexToRgb(color).join(", ")})"
  steps %Q{
    Then "#new-listing-link" should have CSS property "background-color" with value "#{expected_color}"
  }
end

Given(/^community "(.*?)" has default browse view "(.*?)"$/) do |community, browse_view|
  Community.where(ident: community).first.update_attributes(default_browse_view: browse_view)
end

When(/^I change the default browse view to "(.*?)"$/) do |browse_view|
  steps %Q{
    When I select "#{browse_view}" from "community_default_browse_view"
    And I press submit
  }
end

Then(/^I should see the browse view selected as "(.*?)"$/) do |browse_view|
  expect(find(".home-toolbar-button-group .selected")).to have_content(browse_view)
end

Given(/^community "(.*?)" has name display type "(.*?)"$/) do |community, name_display_type|
  Community.where(ident: community).first.update_attributes(name_display_type: name_display_type)
end

When(/^I change the name display type to "(.*?)"$/) do |name_display_type|
  steps %Q{
    When I select "#{name_display_type}" from "community_name_display_type"
    And I press submit
  }
end
