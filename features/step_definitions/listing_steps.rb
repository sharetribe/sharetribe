Then /^I should see image with alt text "([^\"]*)"$/ do | alt_text |
  find('img.listing_main_image')[:alt].should == alt_text
end