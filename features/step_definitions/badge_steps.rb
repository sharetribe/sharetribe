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
  share_types = share_type ? share_type.split(",").collect { |st| Factory(:share_type, :name => st) } : nil
  amount.to_i.times do
    if category
      case category
      when "favor"
        listing = Factory(:listing, :category => category, :share_types => [], :listing_type => listing_type)
      when "rideshare"
        listing = Factory(:listing, :category => category, :share_types => [], :origin => "test", :destination => "test2", :listing_type => listing_type)
      else
        listing = Factory(:listing, :category => category, :share_types => share_types, :listing_type => listing_type)
      end
    else
      listing = Factory(:listing, :category => "item")
    end
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
    Then I should see "You have earned a badge #{I18n.translate('people.profile_badge.' + badge)}!"
    And I should not see "1" within "#logged_in_notifications_icon"
    And I go to the badges page of "kassi_testperson1"
  }
end

When /^I have "(.+)" (item|favor|rideshare) (offer|request) listings$/ do |amount, category, listing_type|
  amount.to_i.times do
    Factory(:listing, :category => category, :listing_type => listing_type)
  end
end

Then /^I create a new (item|favor|rideshare) (offer|request) listing$/ do |category, listing_type|
  steps %Q{
    When I go to the home page
    When I follow "#{listing_type.capitalize} something"
    And I follow "#{category.capitalize}"
    And I fill in "listing_title" with "Test"
    And I press "Save request"
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
    And the system processes jobs
    And I go to the badges page of "kassi_testperson1"
  } 
end