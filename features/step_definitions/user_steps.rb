module UserSteps
  # Updates model's ID and associated IDs
  #
  # Reasoning: Setting custom model for FactoryGirl is cubersome, since id
  # is protected attribute and it's created on validation phase automatically.
  # Thus this helper function
  def force_override_model_id(id, model_instance, model_class, associated_model_classes=[])
    old_id = model_instance.id
    model_class.update_all({:id => id}, {:id => old_id})

    # Associates
    foreign_key = "#{model_class.name.downcase}_id".to_sym
    associated_model_classes.each do |associated_model_class|
      associated_model_class.update_all({foreign_key => id}, {foreign_key => old_id})
    end

    # Reload
    model_class.find(id)
  end
end

World(UserSteps)

Given /^there is a logged in user "(.*?)"$/ do |username|
  steps %Q{
    Given there are following users:
      | person |
      | #{username} |
    And I am logged in as "#{username}"
  }
end

Given /^I am logged in(?: as "([^"]*)")?$/ do |person|
  username = person || "kassi_testperson1"
  person = Person.find_by_username(username)
  login_user_without_browser(person.username)
end

Given /^I am logged in as organization(?: "([^"]*)")?$/ do |org_username|
  username = org_username || "company"
  person = Person.find_by_username(username) || FactoryGirl.create(:person, :username => username, :is_organization => true)
  login_as(person, :scope => :person)
  visit root_path(:locale => :en)
  @logged_in_user = person
end

Given /^I log in(?: as "([^"]*)")?$/ do |person|
  logout_and_login_user(person)
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

Given /^there are following users:$/ do |person_table|
  @people = {}
  person_table.hashes.each do |hash|
    defaults = {
      password: "testi",
      given_name: "Test",
      family_name: "Person"
    }

    username = hash['person']
    id = hash['id']
    membership_created_at = hash['membership_created_at']

    person_opts = defaults.merge({
      username: hash['person'],
    }).merge(hash.except('person', 'membership_created_at'))

    @hash_person, @hash_session = Person.find_by_username(username) || FactoryGirl.create(:person, person_opts)
    @hash_person.save!

    @hash_person = force_override_model_id(id, @hash_person, Person, [Email]) if id

    if hash['email'] then
      @hash_person.emails = [Email.create(:address => hash['email'], :send_notifications => true, :person => @hash_person, :confirmed_at => DateTime.now)]
      @hash_person.save!
    end

    @hash_person.update_attributes({:preferences => { "email_about_new_comments_to_own_listing" => "true", "email_about_new_messages" => "true" }})
    cm = CommunityMembership.find_by_person_id_and_community_id(@hash_person.id, Community.first.id) ||
         CommunityMembership.create(:community_id => Community.first.id,
                                    :person_id => @hash_person.id,
                                    :consent => Community.first.consent,
                                    :status => "accepted")
    cm.update_attribute(:created_at, membership_created_at) if membership_created_at && !membership_created_at.empty?

    attributes_to_update = hash.except('person','person_id', 'locale', 'membership_created_at')
    @hash_person.update_attributes(attributes_to_update) unless attributes_to_update.empty?
    @hash_person.set_default_preferences
    if hash['locale']
      @hash_person.locale = hash['locale']
      @hash_person.save
    end
    @people[username] = @hash_person
  end
end

Given(/^there are (\d+) users with name prefix "([^"]*)" "([^"]*)"$/) do |user_count, given_name, family_name_prefix|
  FactoryGirl.create_list(:person, user_count.to_i, :given_name => given_name, :family_name => "#{family_name_prefix} #{user_count}", :communities => [@current_community])
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
  user = Person.find_by_username(username)
  user.update_attribute(:is_admin, true)
end

Given /^user "([^"]*)" is member of community "([^"]*)"$/ do |username, community|
  user = Person.find_by_username(username)
  community = Community.find_by_domain(community)
  cm = CommunityMembership.find_by_person_id_and_community_id(user.id, community.id)
  CommunityMembership.create(:person_id => user.id, :community_id => community.id) unless cm
end

Given /^"([^"]*)" has admin rights in community "([^"]*)"$/ do |username, community|
  user = Person.find_by_username(username)
  community = Community.find_by_domain(community)
  CommunityMembership.find_by_person_id_and_community_id(user.id, community.id).update_attribute(:admin, true)
end

Given /^"([^"]*)" does not have admin rights in community "([^"]*)"$/ do |username, community|
  user = Person.find_by_username(username)
  community = Community.find_by_domain(community)
  CommunityMembership.find_by_person_id_and_community_id(user.id, community.id).update_attribute(:admin, false)
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

Then /^I should have (confirmed|unconfirmed) email "(.*?)"$/ do |conf, email|
  steps %Q{
    Then user "#{@logged_in_user.username}" should have #{conf} email "#{email}"
  }
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

When /^"(.*?)" is authorized to post a new listing$/ do |username|
  person = Person.find_by_username(username)
  community_membership = CommunityMembership.find_by_person_id_and_community_id(person.id, @current_community.id)
  community_membership.update_attribute(:can_post_listings, true)
end

Given(/^I have just received community updates email$/) do
  # Some tests expect that this really happened in the past, so -1 sec
  last_sent = DateTime.now() - 1.second
  @current_user.update_attribute(:community_updates_last_sent_at, last_sent)
end

Given(/^"(.*?)" follows "(.*?)"$/) do |follower, person|
  person = Person.find_by_username(person)
  follower = Person.find_by_username(follower)
  person.followers << follower unless follower.follows? person
end

Given(/^"(.*?)" follows everyone$/) do |person|
  person = Person.find_by_username(person)
  person.followed_people = Person.all - [ person ]
end

Then(/^I should see (\d+) user profile links$/) do |count|
  expect(page).to have_selector("#profile-followed-people-list .people-fluid-thumbnail-grid-item", :count => count)
end
