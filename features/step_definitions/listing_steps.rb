Given /^a new (item|favor|rideshare|housing) (offer|request) with title "([^"]*)"(?: and with share type "([^"]*)")?$/ do |category, type, title, share_type|
  @listing = Listing.new(:listing_type => type, :category => category, 
                         :title => title, :author_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
                         # author_id of kassi_testperson1

  @listing.share_type = [share_type] if share_type
  unless @listing.valid?
    puts "Listing is not valid! Erros:"
    puts @listing.errors
    @listing.should be_valid
  end
end

Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end
