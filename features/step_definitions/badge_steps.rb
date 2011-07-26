Then /^I should see badge with alt text "([^\"]*)"$/ do | alt_text |
  find("img[title='#{alt_text}']")[:alt].should == alt_text
end

Then /^I should see badge "(.+)"$/ do |badge|
  find("img[src='/images/badges/#{badge}.png']").nil?.should == false
end

Then /^I should not see badge "(.+)"$/ do |badge|
  find("img[src='/images/badges/#{badge}.png']").nil?.should == true
end

Given /^I have "([^"]*)" testimonials? with grade "([^"]*)"(?: from category "([^"]*)")?(?: as "([^"]*)")?(?: with share type "([^"]*)")?$/ do |amount, grade, category, role, share_type|
  listing_type = role ? role.chop.chop : "request"
  amount.to_i.times do
    listing = create_listing(listing_type, category, share_type)
    conversation = Factory(:conversation, :status => "accepted", :listing => listing)
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
      And I follow "Logout"
      And I log in as "kassi_testperson2"
      And I follow "Messages"
      And I follow "Sent"
      And I follow "Give feedback"
      And I follow "#{grade}"
      And I fill in "Textual feedback:" with "Random text"
      And I press "send_testimonial_button"
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
    And I should not see "1" within "#logged_in_notifications_icon"
    And I go to the badges page of "kassi_testperson1"
  }
end

When /^I have "([^"]*)" (item|favor|rideshare) (offer|request) listings(?: with share type "([^"]*)")?$/ do |amount, category, listing_type, share_type|
  amount.to_i.times do
    listing = create_listing(listing_type, category, share_type)
  end
end

Then /^I create a new (item|favor|rideshare) (offer|request) listing(?: with share type "([^"]*)")?$/ do |category, listing_type, share_type|
  steps %Q{ When I go to the home page }
  if listing_type.eql?("offer")
    steps %Q{ When I follow "List your items and skills!" }
  else
    steps %Q{ When I follow "Tell what you need!" }
  end
  steps %Q{ 
    And I follow "#{category.capitalize}"
    And wait for 2 seconds
  }
  if category.eql?("rideshare")
    steps %Q{
      And I fill in "listing_origin" with "Test" 
      And I fill in "listing_destination" with "Test2"
    }
  else
    steps %Q{ And I fill in "listing_title" with "Test" }
  end
  if share_type
    steps %Q{ And I uncheck "lend" }
    share_type.split(",").each do |st|
      steps %Q{
        And I check "#{st}"
      }
    end
  end
  steps %Q{
    And I press "Save #{listing_type}"
    And the system processes jobs
    And I go to the badges page of "kassi_testperson1"
  }
end

When /^I have visited Kassi on "(.+)" different days$/ do |amount|
  @people["kassi_testperson1"].active_days_count = amount
  @people["kassi_testperson1"].last_page_load_date = DateTime.now - 1.month
  @people["kassi_testperson1"].save
end

When /^I have commented that listing "(.+)" times$/ do |amount|
  amount.to_i.times do
    Factory(:comment)
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