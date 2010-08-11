Given /^there is (item|favor|rideshare|housing) (offer|request) with title "([^"]*)" from "([^"]*)"(?: and with share type "([^"]*)")?$/ do |category, type, title, author, share_type|
  @listing = Listing.create(:listing_type => type, 
                             :category => category, 
                             :title => title,
                             :share_type => (share_type ? share_type.split(",") : nil),
                             :author_id => @people[author].id,
                             :valid_until => 3.months.from_now
                            )
end

Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end
