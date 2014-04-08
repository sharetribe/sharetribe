Then /^I should see badge with alt text "([^\"]*)"(?: within "([^"]*)")?$/ do | alt_text, selector |
  with_scope(selector) do
    find("img[title='#{alt_text}']")[:alt].should == alt_text
  end
end

Then /^I should see badge "(.+)"$/ do |badge|
  assert page.has_xpath?("//img[@src='https://s3.amazonaws.com/sharetribe/assets/images/badges/#{badge}.png']")
end

Then /^I should not see badge "(.+)"$/ do |badge|
  assert page.has_no_xpath?("//img[@src='https://s3.amazonaws.com/sharetribe/assets/images/badges/#{badge}.png']")
end

When /^I get the badge "(.+)"$/ do |badge|
  steps %Q{
    And I go to the badges page of "kassi_testperson1"
    And I should see badge "#{badge + '_medium'}"
    When I follow "notifications_link"
    Then I should see "You have earned the badge #{I18n.translate('people.profile_badge.' + badge)}!"
    And I should not see "1" within "#notifications_link"
    And I go to the badges page of "kassi_testperson1"
  }
end

When /^I have "([^"]*)" (item|favor|rideshare) (offer|request) listings(?: with share type "([^"]*)")?$/ do |amount, category, listing_type, share_type|
  share_type ||= listing_type
  amount.to_i.times do
    listing = create_listing(category, share_type)
  end
end

Then /^I create a new (item|favor|rideshare) (offer|request) listing(?: with share type "([^"]*)")?$/ do |category, listing_type, share_type|
  steps %Q{
    When I go to the home page
    And I follow "Post a new listing"
  }

  case listing_type
  when "offer"
    form_listing_type = "I have something"
  when "request"
    form_listing_type = "I need something"
  end

  case category
  when "item"
    form_category = "An item"
  when "favor"
    form_category = "Help"
  when "rideshare"
    form_category = "A shared ride"
  end

  steps %Q{
    And I follow "#{form_listing_type}"
    And I follow "#{form_category}"
  }

  if category.eql? "item"
    steps %Q{
      And I follow "Tools"
    }
  end

  if share_type
    steps %Q{
      And I follow "#{share_type}"
    }
  elsif ["item", "housing"].include? category
    steps %Q{ And I follow "I'm selling it" } if listing_type.eql?("offer")
    steps %Q{ And I follow "I want to buy it" } if listing_type.eql?("request")
  end

  steps %Q{
    And wait for 2 seconds
  }

  if category.eql?("rideshare")
    steps %Q{
      And I fill in "listing_origin" with "Helsinki"
      And I fill in "listing_destination" with "Tampere"
      And wait for 2 seconds
    }
  else
    steps %Q{ And I fill in "listing_title" with "Test" }
  end

  steps %Q{
    And I press "Save listing"
    And the system processes jobs
    And I go to the badges page of "kassi_testperson1"
  }

end

When /^I have visited Sharetribe on "(.+)" different days$/ do |amount|
  @people["kassi_testperson1"].active_days_count = amount
  @people["kassi_testperson1"].last_page_load_date = DateTime.now - 1.month
  @people["kassi_testperson1"].save
end

When /^I have commented that listing "(.+)" times$/ do |amount|
  amount.to_i.times do
    FactoryGirl.create(:comment, :author => @people["kassi_testperson1"])
  end
end

When /^I comment that listing$/ do
  steps %Q{
    When I go to the listing page
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    And wait for 2 seconds
    And the system processes jobs
    And wait for 2 seconds
    And I go to the badges page of "kassi_testperson1"
  }
end

When /^I belong to test group "(.+)"$/ do |group_number|
  @people["kassi_testperson1"].update_attribute(:test_group_number, group_number)
end
