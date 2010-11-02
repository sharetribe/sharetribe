Given /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?$/ do |category, type, title, author, share_type|
  @listing = Listing.create!(:listing_type => type, 
                             :category => category, 
                             :title => title,
                             :description => "test",
                             :tag_list => "tools, test",
                             :share_type_attributes => (share_type ? share_type.split(",") : nil),
                             :author_id => (@people && @people[author] ? @people[author].id : Person.first.id),
                             :valid_until => 3.months.from_now,
                             :visibility => "everybody"
                            )
end

Given /^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/ do |type, origin, destination, author|
  @listing = Listing.create!(:listing_type => type, 
                             :category => "rideshare", 
                             :origin => origin,
                             :destination => destination,
                             :author_id => @people[author].id,
                             :valid_until => 3.months.from_now
                            )
end

Given /^that listing is closed$/ do
  @listing.update_attribute(:open, false)
end

Given /^visibility of that listing is "([^"]*)"$/ do |visibility|
  @listing.update_attribute(:visibility, visibility)
end

Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end

Then /^There should be a rideshare (offer|request) from "([^"]*)" to "([^"]*)" starting at "([^"]*)"$/ do |share_type, origin, destination, time|
  listings = Listing.find_all_by_title("#{origin} - #{destination}")
  
end

