module UserSteps
  # Updates model's ID and associated IDs
  #
  # Reasoning: Setting custom model for FactoryGirl is cubersome, since id
  # is protected attribute and it's created on validation phase automatically.
  # Thus this helper function
  def force_override_model_id(id, model_instance, model_class, associated_model_classes=[])
    old_id = model_instance.id
    model_class.where(id: old_id).update_all(id: id)

    # Associates
    foreign_key = "#{model_class.name.downcase}_id".to_sym
    associated_model_classes.each do |associated_model_class|
      associated_model_class.where(foreign_key => old_id).update_all(foreign_key => id)
    end

    # Reload
    model_class.find(id)
  end
end

World(UserSteps)

Given /^I am logged in(?: as "([^"]*)")?$/ do |person|
  username = person || "kassi_testperson1"
  person = Person.find_by(username: username)
  login_user_without_browser(person.username)
end

Given /^I log in(?: as "([^"]*)")?$/ do |person|
  logout_and_login_user(person)
end

Given /^I am not logged in$/ do
  logout_user_without_browser
end

Given /^my given name is "([^"]*)"$/ do |name|
  # Using direct model (and ASI) access here
  cookie = nil
  @test_person = Person.find_by_username "kassi_testperson1"
  @test_person.set_given_name(name)
end

Given /^user "(.*?)" has additional email "(.*?)"$/ do |username, email|
  Email.create(:person => Person.find_by(username: username), :address => email, :confirmed_at => Time.now, community_id: @current_community.id)
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
    community = Community.find_by(ident: hash['community']) || Community.first

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
    }).merge(hash.except('person', 'membership_created_at', 'community'))

    @hash_person, @hash_session = Person.find_by(username: username) || FactoryGirl.create(:person, person_opts)
    @hash_person.community_id = community.id
    @hash_person.save!

    @hash_person = force_override_model_id(id, @hash_person, Person, [Email]) if id

    if hash['email'] then
      @hash_person.emails = [Email.create(
                              address: hash['email'],
                              send_notifications: true,
                              person: @hash_person,
                              confirmed_at: DateTime.now,
                              community_id: community.id)]
      @hash_person.save!
    end

    @hash_person.update_attributes({:preferences => { "email_about_new_comments_to_own_listing" => "true", "email_about_new_messages" => "true" }})
    cm = CommunityMembership.find_by_person_id_and_community_id(@hash_person.id, community.id) ||
         CommunityMembership.create(:community_id => community.id,
                                    :person_id => @hash_person.id,
                                    :consent => community.consent,
                                    :status => "accepted")
    cm.update_attribute(:created_at, membership_created_at) if membership_created_at && !membership_created_at.empty?

    attributes_to_update = hash.except('person','person_id', 'locale', 'membership_created_at', 'community')
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
  FactoryGirl.create_list(:person, user_count.to_i,
                          given_name: given_name,
                          family_name: "#{family_name_prefix} #{user_count}",
                          community_id: @current_community.id,
                          communities: [@current_community])
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

Given /^"([^"]*)" is superadmin$/ do |username|
  user = Person.find_by(username: username)
  user.update_attribute(:is_admin, true)
end

Given /^"([^"]*)" has admin rights in community "([^"]*)"$/ do |username, community|
  user = Person.find_by(username: username)
  community = Community.where(ident: community).first
  CommunityMembership.find_by_person_id_and_community_id(user.id, community.id).update_attribute(:admin, true)
end

Then /^I should not see my username$/ do
  expect(page).to have_no_content(Person.order("created_at").last.username)
end

Then /^user "([^"]*)" (should|should not) have "([^"]*)" with value "([^"]*)"$/ do |username, verb, attribute, value|
  user = Person.find_by(username: username)
  expect(user).not_to be_nil
  verb = verb.gsub(" ", "_")
  value = nil if value == "nil"
  user.send(attribute).send(verb) == value
end

Then /^user "(.*?)" should have email "(.*?)"$/ do |username, email|
  p = Person.find_by(username: username)
  e = Email.find_by_person_id_and_address(p.id, email)

  expect(e).not_to be_nil
end

Then /^I should have (confirmed|unconfirmed) email "(.*?)"$/ do |conf, email|
  steps %Q{
    Then user "#{@logged_in_user.username}" should have #{conf} email "#{email}"
  }
end

Then /^user "(.*?)" should have (confirmed|unconfirmed) email "(.*?)"$/ do |username, conf, email|
  p = Person.find_by(username: username)
  e = Email.find_by_person_id_and_address(p.id, email)

  expect(e).not_to be_nil

  if conf == "unconfirmed"
    expect(e.confirmed_at).to be_nil
  end

  if conf == "confirmed"
    expect(e.confirmed_at).not_to be_nil
  end
end

When /^"(.*?)" is authorized to post a new listing$/ do |username|
  person = Person.find_by(username: username, community_id: @current_community.id)
  community_membership = CommunityMembership.find_by_person_id_and_community_id(person.id, @current_community.id)
  community_membership.update_attribute(:can_post_listings, true)
end

Given(/^I have just received community updates email$/) do
  # Some tests expect that this really happened in the past, so -1 sec
  last_sent = DateTime.now() - 1.second
  @current_user.update_attribute(:community_updates_last_sent_at, last_sent)
end

Given(/^"(.*?)" follows "(.*?)"$/) do |follower, person|
  person = Person.find_by(username: person)
  follower = Person.find_by(username: follower)
  person.followers << follower unless follower.follows? person
end

Given(/^"(.*?)" follows everyone$/) do |person|
  person = Person.find_by(username: person)
  person.followed_people = Person.all - [ person ]
end

Then(/^I should see (\d+) user profile links$/) do |count|
  expect(page).to have_selector("#profile-followed-people-list .people-fluid-thumbnail-grid-item", :count => count)
end

Given /^I have confirmed paypal account(?: as "([^"]*)")?(?: for community "([^"]*)")?$/ do |person, community_name|
  username = person || "kassi_testperson1"
  person = Person.find_by(username: username)
  community = Community.where(ident: community_name || "test").first
  paypal_account = FactoryGirl.create(:paypal_account, person_id: person.id, community_id: community.id)
  FactoryGirl.create(:order_permission, paypal_account: paypal_account)
  FactoryGirl.create(:billing_agreement, paypal_account: paypal_account)
end

Given /^I have confirmed stripe account(?: as "([^"]*)")?(?: for community "([^"]*)")?$/ do |person, community_name|
  username = person || "kassi_testperson1"
  person = Person.find_by(username: username)
  community = Community.where(ident: community_name || "test").first
  FactoryGirl.create(:stripe_account, person_id: person.id, community_id: community.id, stripe_seller_id: 'ABC')
end

