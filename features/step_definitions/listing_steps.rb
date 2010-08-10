Given /^a new (item|favor|rideshare|housing) (offer|request) with title "([^"]*)"(?: and with share type "([^"]*)")?$/ do |category, type, title, share_type|
  @listing = Factory.build(:listing, :listing_type => type, :category => category, :title => title, :share_type => (share_type ? share_type.split(",") : nil))
  unless @listing.valid?
    puts "Listing is not valid! Erros:"
    puts @listing.errors
    @listing.should be_valid
  end
  @listing.save
end

Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end
