Given /^I have "([^"]*)" testimonials? with grade "([^"]*)"$/ do |amount, grade|
  amount.to_i.times do
    FactoryGirl.create(:testimonial, author: @people["kassi_testperson2"], :receiver => @people["kassi_testperson1"], grade: grade)
  end
end
