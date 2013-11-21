Given /^I am logged in(?: as "([^"]*)")?$/ do |person|
  username = person || "kassi_testperson1"
  person = Person.find_by_username(username) || FactoryGirl.create(:person, :username => username)
  login_as(person, :scope => :person)
  visit root_path(:locale => :en)
  @logged_in_user = person
end

Given /^I am logged in as organization(?: "([^"]*)")?$/ do |org_username|
  username = org_username || "company"
  person = Person.find_by_username(username) || FactoryGirl.create(:person, :username => username, :is_organization => true)
  login_as(person, :scope => :person)
  visit root_path(:locale => :en)
  @logged_in_user = person
end

Given /^I log in(?: as "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("main_person_login", :with => (person ? person : "kassi_testperson1"))
  fill_in("main_person_password", :with => "testi")
  click_button(:main_log_in_button)
end

Given /^I log in to this private community(?: as "([^"]*)")?$/ do |person|
  visit login_path(:locale => :en)
  fill_in("person[login]", :with => (person ? person : "kassi_testperson1"))
  fill_in("person[password]", :with => "testi")
  click_button("Log in")
end

Given /^I am not logged in$/ do
  # TODO Check here that not logged in
end

Given /^my given name is "([^"]*)"$/ do |name|
  # Using direct model (and ASI) access here
  cookie = nil
  @test_person = Person.find_by_username "kassi_testperson1"
  @test_person.set_given_name(name)
end

Given /^my phone number in my profile is "([^"]*)"$/ do |phone_number|
  raise RuntimeException.new("@session neede to be set before the line 'my phone number...'") unless @session
  @test_person = Person.find(@session.person_id) if @test_person.nil?
  @test_person.set_phone_number(phone_number)
end

Given /^user "(.*?)" has additional email "(.*?)"$/ do |username, email|
  Email.create(:person => Person.find_by_username(username), :address => email, :confirmed_at => Time.now)
end

Given /^there will be and error in my Facebook login$/ do 
  OmniAuth.config.mock_auth[:facebook] = :access_denied
end

Given /^there will be no email returned in my Facebook login$/ do 
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new( {
      :provider => 'facebook',
      :uid => '597015435',
      :extra =>{
        :raw_info => {
          :first_name => "Jackie",
          :last_name => "Brownie",
          :username => "jackety-jack",
          :id => '597015435'
        }
      }
    })
end

Given /^"(.*?)" has payout details filled$/ do |username|
  person = Person.find_by_username(username)
  person.bank_account_owner_name = person.name
  person.bank_account_owner_address = "Any street 123"
  person.iban = "GR16 0110 1250 0000 0001 2300 695"
  person.bic = "DEUTDEFF500"
  person.save!
end


Given /^there are following users:$/ do |person_table|
  @people = {}
  person_table.hashes.each do |hash|
    @hash_person, @hash_session = get_test_person_and_session(hash['person'])

    if hash['email'] then
      @hash_person.emails = [Email.create(:address => hash['email'], :send_notifications => true, :person => @hash_person)]
      @hash_person.save!
    end

    @hash_person.update_attributes({:preferences => { "email_about_new_comments_to_own_listing" => "true", "email_about_new_messages" => "true" }})
    #unless CommunityMembership.find_by_person_id_and_community_id(@hash_person.id, Community.first.id)
      CommunityMembership.create(:community_id => Community.first.id, :person_id => @hash_person.id, :consent => Community.first.consent, :status => "accepted")
    #end
    attributes_to_update = hash.except('person','person_id', 'locale')
    @hash_person.update_attributes(attributes_to_update) unless attributes_to_update.empty?
    @hash_person.set_default_preferences
    if hash['locale'] 
      @hash_person.locale = hash['locale']
      @hash_person.save
    end
    @people[hash['person']] = @hash_person
  end
end

When /^I log out$/ do
  find(".user-menu-toggle").click
  click_link "Log out"
end

# Filling in with random strings
When /^(?:|I )fill in "([^"]*)" with random (username|email)(?: within "([^"]*)")?$/ do |field, value, selector|
  @values ||= {}
  case value
  when "username"
    value = generate_random_username
    @values["username"] = value
  when "email"
    value = "#{generate_random_username}@example.com"
    @values["email"] = value
    Thread.current[:latest_used_random_email] = value
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

Given /^"([^"]*)" is superadmin$/ do |username|
  @people[username].update_attribute(:is_admin, true)
end

Given /^"([^"]*)" has admin rights in community "([^"]*)"$/ do |username, community|
  CommunityMembership.find_by_person_id_and_community_id(@people[username].id, Community.find_by_name(community).id).update_attribute(:admin, true)
end

Then /^I should see my username$/ do
  username = Person.order("updated_at").last.username
  if @values && @values["username"]
    # puts "it seems there username of last created person is stored, so use that"
    username = @values["username"]
  end
  if page.respond_to? :should
    page.should have_content(username)
  else
    assert page.has_content?(username)
  end
end

Then /^I should not see my username$/ do
  if page.respond_to? :should
    page.should have_no_content(Person.order("created_at").last.username)
  else
    assert page.has_no_content?(Person.order("created_at").last.username)
  end
end

Then /^user "([^"]*)" (should|should not) have "([^"]*)" with value "([^"]*)"$/ do |username, verb, attribute, value|
  user = Person.find_by_username(username)
  user.should_not be_nil
  verb = verb.gsub(" ", "_")
  value = nil if value == "nil"
  user.send(attribute).send(verb) == value
end

Then /^user "(.*?)" should have email "(.*?)"$/ do |username, email|
  p = Person.find_by_username(username)
  e = Email.find_by_person_id_and_address(p.id, email)
  
  e.should_not be_nil
end

Then /^user "(.*?)" should have (confirmed|unconfirmed) email "(.*?)"$/ do |username, conf, email|
  p = Person.find_by_username(username)
  e = Email.find_by_person_id_and_address(p.id, email)
  
  e.should_not be_nil

  if conf == "unconfirmed"
    e.confirmed_at.should be_nil
  end

  if conf == "confirmed"
    e.confirmed_at.should_not be_nil
  end
end

Then /^I should be logged in$/ do
  if page.respond_to? :should
    page.should have_no_css("#login-link")
  else
    assert page.has_no_css?("#login-link")
  end
end

Then /^I should not be logged in$/ do
  if page.respond_to? :should
    page.should have_css("#login-link")
  else
    assert page.has_css?("#login-link")
  end
end

