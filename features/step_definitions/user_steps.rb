Given /^I am logged in$/ do
  visit login_path(:locale => :en)
  fill_in("username", :with => "kassi_testperson1")
  fill_in("password", :with => "testi")
  click_button("Login")
end

Given /^I am not logged in$/ do
  # TODO Check here that not logged in
end

When /^I enter correct credentials$/ do
  @session = Session.create( {:username => "kassi_testperson1", :password => "testi"})
end

Then /^I should be logged in$/ do
  @session.check["entry"]["user_id"].should_not be_blank
end
