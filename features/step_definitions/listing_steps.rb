
Given /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?$/ do |category, type, title, author, share_type|
  @listing = Listing.create!(:listing_type => type, 
                             :category => category, 
                             :title => title,
                             :description => "test",
                             :tag_list => "tools, test",
                             :share_type => (share_type ? share_type.split(",") : nil),
                             :author_id => (@people && @people[author] ? @people[author].id : Person.first.id),
                             :valid_until => 3.months.from_now
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

Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end
