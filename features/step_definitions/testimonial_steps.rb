Then /^I (should|should not) see (big|small) (happy|semihappy|content|semiunhappy|unhappy) face (with non-transparent background|with transparent background)$/ do |hidden, face_size, face_type, background|
  case face_type
  when "happy"
    face_number = "5"
  when "semihappy"
    face_number = "4"
  when "content"
    face_number = "3"
  when "semiunhappy"
    face_number = "2"
  when "unhappy"
    face_number = "1"
  end
  face_size_label = face_size.eql?("big") ? "_big" : ""
  if background.eql?("with non-transparent background")
    profile_label = "profile_"
  else
    profile_label = face_size.eql?("big") ? "profile_" : ""
  end
  image_class = ".#{profile_label}feedback_average_image_#{face_number}#{face_size_label}"
  if hidden.eql?("should not")
    page.should_not have_css(image_class)
  else
    page.should have_css(image_class)
  end
end

Given /^I have "([^"]*)" testimonials? with grade "([^"]*)"$/ do |amount, grade|
  amount.to_i.times do
    FactoryGirl.create(:testimonial, author: @people["kassi_testperson2"], :receiver => @people["kassi_testperson1"], grade: grade)
  end
end
