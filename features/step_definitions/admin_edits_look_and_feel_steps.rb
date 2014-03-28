Given(/^community "(.*?)" has default browse view "(.*?)"$/) do |community, browse_view|
  Community.find_by_domain(community).update_attributes(default_browse_view: browse_view)
end

Given(/^I change the default browse view to "(.*?)"$/) do |browse_view|
  pending # express the regexp above with the code you wish you had
end

Given(/^I navigate to the homepage$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see the browse view selected as "(.*?)"$/) do |browse_view|
  pending # express the regexp above with the code you wish you had
end

