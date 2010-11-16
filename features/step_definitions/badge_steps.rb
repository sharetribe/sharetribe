Then /^I should see badge with alt text "([^\"]*)"$/ do | alt_text |
  find("img[title='#{alt_text}']")[:alt].should == alt_text
end

Then /^I should see badge "(.+)"$/ do |badge|
  find("img[src='/images/badges/#{badge}.png']").nil?.should == false
end

Then /^I should not see badge "(.+)"$/ do |badge|
  find("img[src='/images/badges/#{badge}.png']").nil?.should == true
end

Given /^I have "(.+)" testimonials? with grade "(.+)"$/ do |amount, grade|
  amount.to_i.times do
    conversation = Factory(:conversation, :status => "accepted")
    conversation.participants << @people["kassi_testperson1"] << @people["kassi_testperson2"]
    participation = Participation.find_by_person_id_and_conversation_id(@people["kassi_testperson1"].id, conversation.id)
    @testimonial = Testimonial.create!(:grade => 0.75, :text => "Yeah", :author_id => @people["kassi_testperson2"], :receiver_id => @people["kassi_testperson1"], :participation_id => participation.id)
  end
end

When /^I get "(.+)" testimonials? with grade "(.+)"$/ do |amount, grade|
  amount.to_i.times do
    steps %Q{
      Given there is favor offer with title "massage" from "kassi_testperson2"
      And there is a message "I request this" from "kassi_testperson1" about that listing
      And the request is accepted
      And I follow "Logout"
      And I log in as "kassi_testperson2"
      And I follow "Messages"
      And I follow "Give feedback"
      And I follow "#{grade}"
      And I fill in "Textual feedback:" with "Random text"
      And I press "send_testimonial_button"
      And I follow "Logout"
      And I log in as "kassi_testperson2"
      And the system processes jobs
      And I go to the badges page of "kassi_testperson1"
    }
  end
end