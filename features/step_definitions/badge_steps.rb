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

Given /^I have "([^"]*)" testimonials? with grade "([^"]*)"(?: from category "([^"]*)")?(?: as "([^"]*)")?(?: with share type "([^"]*)")?$/ do |amount, grade, category, role, share_type|
  listing_type = find_or_create_share_type(role ? role.chop.chop : "request")
  category = find_or_create_category(category || "item")
  share_type ||= listing_type
  amount.to_i.times do
    listing = create_listing(category, share_type)
    conversation = FactoryGirl.create(:conversation, :status => "accepted", :listing => listing)
    conversation.participants << @people["kassi_testperson1"] << @people["kassi_testperson2"]
    participation = Participation.find_by_person_id_and_conversation_id(@people["kassi_testperson1"].id, conversation.id)
    @testimonial = Testimonial.create!(:grade => 0.75, :text => "Yeah", :author_id => @people["kassi_testperson2"], :receiver_id => @people["kassi_testperson1"], :participation_id => participation.id)
  end
end

When /^I get "([^"]*)" testimonials? with grade "([^"]*)"(?: from category "([^"]*)")?(?: with share type "([^"]*)")?$/ do |amount, grade, category, share_type|
  amount.to_i.times do
    if category
      if category.eql?("rideshare")
        steps %Q{ Given there is rideshare offer from "Otaniemi" to "Turkkunen" by "kassi_testperson1" }
      else
        if share_type
          steps %Q{ Given there is #{category} offer with title "test" from "kassi_testperson1" and with share type "#{share_type}" }
        else
          steps %Q{ Given there is #{category} offer with title "test" from "kassi_testperson1" }
        end  
      end
    else
      steps %Q{ Given there is favor offer with title "massage" from "kassi_testperson1" }
    end
    steps %Q{
      And there is a message "I request this" from "kassi_testperson2" about that listing
      And the request is accepted
      And I click ".user-menu-toggle"
      And I follow "Logout"
      And I log in as "kassi_testperson2"
      And I follow "inbox-link"
      And I follow "Sent"
      And I follow "Give feedback"
      And I follow "#{grade}"
      And I fill in "How did things go:" with "Random text"
      And I press "send_testimonial_button"
      And I click ".user-menu-toggle"
      And I follow "Logout"
      And I log in as "kassi_testperson1"
      And the system processes jobs
      And I go to the badges page of "kassi_testperson1"
    }
  end
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
  steps %Q{ When I go to the home page }
  if listing_type.eql?("offer")
    steps %Q{ When I follow "Post a new listing!" }
  else
    steps %Q{ When I follow "Post a new listing!" }
  end
  case category
  when "item"
    form_category = "an item"
  when "favor"
    form_category = "a service"
  when "rideshare"
    form_category = "a ride"   
  end
  steps %Q{ 
    And I follow "#{form_category}"
    And wait for 2 seconds
  }
  if category.eql?("rideshare")
    steps %Q{
      And I fill in "listing_origin" with "Helsinki" 
      And I fill in "listing_destination" with "Tampere"
      And wait for 2 seconds
    }
  else
    if ["item", "housing"].include?(category)
      steps %Q{ And I select "Selling" from "listing_share_type" } if listing_type.eql?("offer")
      steps %Q{ And I select "Buying" from "listing_share_type" } if listing_type.eql?("request")
    end
    steps %Q{ And I fill in "listing_title" with "Test" }
  end
  if share_type
    steps %Q{ And I select "#{share_type.capitalize}ing" from "listing_share_type"}
  end
  steps %Q{
    And I press "Save #{listing_type}"
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