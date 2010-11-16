Then /^I should see badge with alt text "([^\"]*)"$/ do | alt_text |
  find("img[title='#{alt_text}']")[:alt].should == alt_text
end

Then /^I should see badge "(.+)"$/ do |badge|
  !find("img[src='/images/badges/#{badge}.png']").nil?
end

Then /^I should not see badge "(.+)"$/ do |badge|
  find("img[src='/images/badges/#{badge}.png']").nil?
end


When /^I have "(.+)" testimonials? with grade "(.+)"$/ do |amount, grade|
  amount.to_i.times
    conversation = Factory(:conversation, :status => "accepted")
    conversation.participants << @people["kassi_testperson1"] << @people["kassi_testperson2"]
    participation = Participation.find_by_person_id_and_conversation_id(@test_person.id, @conversation.id)
    @testimonial = Testimonial.new(:grade => 0.75, :text => "Yeah", :author_id => @test_person.id, :receiver_id => @test_person2.id, :participation_id => @participation.id)
  end
end

When /^I get "(.+)" testimonials? with grade "(.+)"$/ do |amount, grade|
  amount.to_i.times
    steps %Q{
    
    }
  end
end