Then /^I should see badge with alt text "([^\"]*)"$/ do | alt_text |
  find("img[title='#{alt_text}']")[:alt].should == alt_text
end
