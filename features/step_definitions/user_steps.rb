Given /^I am logged in(?: as "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("username", :with => (person ? person : "kassi_testperson1"))
  fill_in("password", :with => "testi")
  click_button("Log in")
end

Given /^I log in(?: as "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("username", :with => (person ? person : "kassi_testperson1"))
  fill_in("password", :with => "testi")
  click_button("Log in")
end

Given /^I am not logged in$/ do
  # TODO Check here that not logged in
end

Given /^my given name is "([^"]*)"$/ do |name|
  # Using direct model (and ASI) access here
  @session = Session.create({:username => "kassi_testperson1", :password => "testi" })
  @test_person = Person.find(@session.person_id)
  @test_person.set_given_name(name, @session.cookie)
end

Given /^my phone number in my profile is "([^"]*)"$/ do |phone_number|
  raise RuntimeException.new("@session neede to be set before the line 'my phone number...'") unless @session
  @test_person = Person.find(@session.person_id) if @test_person.nil?
  @test_person.set_phone_number(phone_number, @session.cookie)
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
    #unless CommunityMembership.find_by_person_id_and_community_id(@hash_person.id, Community.first.id)
      CommunityMembership.create(:community_id => Community.first.id, :person_id => @hash_person.id)
    #end
    @people[hash['person']] = @hash_person
  end
end

# Filling in with random strings
When /^(?:|I )fill in "([^"]*)" with random (username|email)(?: within "([^"]*)")?$/ do |field, value, selector|
  @values = {}
  case value
  when "username"
    value = generate_random_username
    @values["username"] = value
  when "email"
    value = "#{generate_random_username}@example.com"
    @values["email"] = value
  end
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should contain the (username|email) I gave$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{@values[value]}/
    else
      assert_match(/#{@values[value]}/, field_value)
    end
  end
end

Then /^(?:|I )should see the (username|email) I gave(?: within "([^"]*)")?$/ do |value, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(@values[value])
    else
      assert page.has_content?(@values[value])
    end
  end
end

# Adds a test person to ASI but not in Kassi
Given /^I already have an OtaSizzle account$/ do
  cookie = Session.create.cookie
  @username = generate_random_username
  @password = "test"
  person_hash = {:person => {:username => @username, :email => "#{@username}@mail.com", :password => @password, :consent => "Test"} }
  response = PersonConnection.create_person(person_hash, cookie)
end

When /^I fill in username with my OtaSizzle username$/ do
  fill_in("username", :with => @username)
end

When /^I fill in password with my OtaSizzle password$/ do
  fill_in("password", :with => @password)
end

Given /^"([^"]*)" has admin rights$/ do |username|
  @people[username].update_attribute(:is_admin, true)
end

Given /^"([^"]*)" has admin rights in community "([^"]*)"$/ do |username, community|
  CommunityMembership.find_by_person_id_and_community_id(@people[username].id, Community.find_by_name(community).id).update_attribute(:admin, true)
end
