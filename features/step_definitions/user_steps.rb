Given /^I am logged in(?: with "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("username", :with => (person ? person :"kassi_testperson1"))
  fill_in("password", :with => "testi")
  click_button("Login")
end

Given /^I am not logged in$/ do
  # TODO Check here that not logged in
end

Given /^My given name is "([^"]*)"$/ do |name|
  # Using direct model (and ASI) access here
  session = Session.create({:username => "kassi_testperson1", :password => "testi" })
  test_person = Person.find(session.person_id)
  test_person.set_given_name(name, session.cookie)
end


When /^I enter correct credentials$/ do
  @session = Session.create( {:username => "kassi_testperson1", :password => "testi"})
end

Then /^I should be logged in$/ do
  @session.check["entry"]["user_id"].should_not be_blank
end
