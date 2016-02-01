Given /^I have "([^"]*)" testimonials? with grade "([^"]*)"$/ do |amount, grade|
  amount.to_i.times do

    tr = FactoryGirl.create(:transaction, community: @current_community)

    FactoryGirl.create(:testimonial,
                        author: @people["kassi_testperson2"],
                        receiver: @people["kassi_testperson1"],
                        grade: grade,
                        tx: tr
                      )
  end
end
