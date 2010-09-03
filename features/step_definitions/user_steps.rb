Given /^I am logged in(?: as "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("username", :with => (person ? person : "kassi_testperson1"))
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

Given /^there are following users:$/ do |person_table|
  @people = {}
  person_table.hashes.each do |hash|
    @hash_person, @hash_session = get_test_person_and_session(hash['person'])
    @hash_person.update_attributes({:preferences => { "email_about_new_comments_to_own_listing" => "true", "email_about_new_messages" => "true" }}, @hash_session.cookie)
    @people[hash['person']] = @hash_person
  end
end


# Filling in with random strings

When /^(?:|I )fill in "([^"]*)" with random (username|email)(?: within "([^"]*)")?$/ do |field, value, selector|
  case value
    when "username" then value = generate_random_username
    when "email"    then value = "#{generate_random_username}@example.com"
  end
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end