module CommunitySteps

  def use_payment_gateway(community_domain, gateway_name, commission)
    gateway_name ||= "Checkout"
    commission ||= "8"

    community = Community.find_by_domain(community_domain)
    community.update_attributes(:vat => "24", :commission_from_seller => commission.to_i)

    if gateway_name == "Checkout"
      FactoryGirl.create(:checkout_payment_gateway, :community => community, :type => gateway_name)
    else
      FactoryGirl.create(:braintree_payment_gateway, :community => community, :type => gateway_name)
    end
  end
end

World(CommunitySteps)

Given /^there are following communities:$/ do |communities_table|
  communities_table.hashes.each do |hash|
    domain = hash[:community]
    existing_community = Community.find_by_domain(domain)
    existing_community.destroy if existing_community
    @hash_community = FactoryGirl.create(:community, :name => domain, :domain => domain, :settings => {"locales" => ["en", "fi"]})

    attributes_to_update = hash.except('community')
    @hash_community.update_attributes(attributes_to_update) unless attributes_to_update.empty?
  end
end

Given /^the test community has following available locales:$/ do |locale_table|
  @locales = []
  locale_table.hashes.each do |hash|
    @locales << hash['locale']
  end

  #here is expected that the first community is the test community where the subdomain is pointing by default
  community = Community.first
  community.update_attributes({:settings => { "locales" => @locales }})
  community.locales.each do |locale|
    unless community.community_customizations.find_by_locale(locale)
      community.community_customizations.create(:locale => locale, :name => "Sharetribe")
    end
  end
end

Given /^the terms of community "([^"]*)" are changed to "([^"]*)"$/ do |community, terms|
  Community.find_by_domain(community).update_attribute(:consent, terms)
end

Given /^"(.*?)" is a member of community "(.*?)"$/ do |username, community_name|
  community = Community.find_by_name!(community_name)
  person = Person.find_by_username!(username)
  membership = FactoryGirl.create(:community_membership, :person => person, :community => community)
  membership.save!
end

Then /^Most recently created user should be member of "([^"]*)" community with(?: status "(.*?)" and)? its latest consent accepted(?: with invitation code "([^"]*)")?$/ do |community_domain, status, invitation_code|
    # Person.last seemed to return unreliable results for some reason
    # (kassi_testperson1 instead of the actual newest person, so changed
    # to look for the latest CommunityMembership)
    status ||= "accepted"

    community = Community.find_by_domain(community_domain)
    CommunityMembership.last.community.should == community
    CommunityMembership.last.consent.should == community.consent
    CommunityMembership.last.status.should == status
    CommunityMembership.last.invitation.code.should == invitation_code if invitation_code.present?
end

Given /^given name and last name are not required in community "([^"]*)"$/ do |community|
  Community.find_by_domain(community).update_attribute(:real_name_required, 0)
end

Given /^community "([^"]*)" requires invite to join$/ do |community|
  Community.find_by_domain(community).update_attribute(:join_with_invite_only, true)
end

Given /^community "([^"]*)" does not require invite to join$/ do |community|
  Community.find_by_domain(community).update_attribute(:join_with_invite_only, false)
end

Given /^community "([^"]*)" requires users to have an email address of type "(.*?)"$/ do |community, email|
  Community.find_by_domain(community).update_attribute(:allowed_emails, email)
end

Given /^the community has payments in use(?: via (\w+))?(?: with seller commission (\w+))?$/ do |gateway_name, commission|
  use_payment_gateway(@current_community.domain, gateway_name, commission)
end

Given /^community "([^"]*)" has payments in use(?: via (\w+))?(?: with seller commission (\w+))?$/ do |community_domain, gateway_name, commission|
  use_payment_gateway(community_domain, gateway_name, commission)
end

Given /^users (can|can not) invite new users to join community "([^"]*)"$/ do |verb, community|
  can_invite = verb == "can"
  Community.find_by_domain(community).update_attribute(:users_can_invite_new_users, can_invite)
end

Given /^there is an invitation for community "([^"]*)" with code "([^"]*)"(?: with (\d+) usages left)?$/ do |community, code, usages_left|
  inv = Invitation.new(:community => Community.find_by_domain(community), :code => code, :inviter_id => @people.first[1].id)
  inv.usages_left = usages_left if usages_left.present?
  inv.save
end

Then /^Invitation with code "([^"]*)" should have (\d+) usages_left$/ do |code, usages|
  Invitation.find_by_code(code).usages_left.should == usages.to_i
end

When /^I move to community "([^"]*)"$/ do |community|
  Capybara.default_host = "#{community}.lvh.me"
  Capybara.app_host = "http://#{community}.lvh.me:9887"
  @current_community = Community.find_by_domain(community)
end

When /^I arrive to sign up page with the link in the invitation email with code "(.*?)"$/ do |code|
  visit "/en/signup?code=#{code}"
end

Given /^there is an existing community with "([^"]*)" in allowed emails and with slogan "([^"]*)"$/ do |email_ending, slogan|
  @existing_community = FactoryGirl.create(:community, :allowed_emails => email_ending, :slogan => slogan, :category => "company")
end

Given /^show me existing community$/ do
  puts "Email ending: #{@existing_community.allowed_emails}"
end

Then /^community "(.*?)" should require invite to join$/ do |community|
   Community.find_by_domain(community).join_with_invite_only.should be_truthy
end

Then /^community "(.*?)" should not require invite to join$/ do |community|
   Community.find_by_domain(community).join_with_invite_only.should_not be_truthy
end

Given /^community "(.*?)" is private$/ do |community_domain|
  Community.find_by_domain(community_domain).update_attributes({:private => true})
end

Given /^community "(.*?)" has following category structure:$/ do |community, categories|
  current_community = Community.find_by_domain(community)
  old_category_ids = current_community.categories.collect(&:id)

  current_community.categories = categories.hashes.map do |hash|
    category = current_community.categories.create!
    category.translations.create!(:name => hash['fi'], :locale => 'fi')
    category.translations.create!(:name => hash['en'], :locale => 'en')
    category.transaction_types << current_community.transaction_types.first
    if hash['category_type'].eql?("main")
      @top_level_category = category
    else
      category.update_attribute(:parent_id, @top_level_category.id)
    end
    category
  end

  # Clean old
  current_community.categories.select do |category|
    old_category_ids.include? category.id
  end.each do |category|
    category.destroy!
  end
end

Given /^community "(.*?)" has following transaction types enabled:$/ do |community, transaction_types|
  current_community = Community.find_by_domain(community)
  current_community.transaction_types.destroy_all

  current_community.transaction_types << transaction_types.hashes.map do |hash|
    transaction_type = FactoryGirl.create(:transaction_type, :type => hash['transaction_type'], :community_id => current_community.id)
    transaction_type.translations.create(:name => hash['fi'], :action_button_label => (hash['button'] || "Action"), :locale => 'fi')
    transaction_type.translations.create(:name => hash['en'], :action_button_label => (hash['button'] || "Action"), :locale => 'en')
    transaction_type
  end
end

Given /^the community has transaction type (Sell|Rent) with name "(.*?)" and action button label "(.*?)"$/ do |type_class, name, action_button_label|
  translations = [FactoryGirl.build(:transaction_type_translation, locale: "en", name: name, action_button_label: action_button_label)]
  @transaction_type = FactoryGirl.create("transaction_type_#{type_class.downcase}".to_sym, translations: translations, community: @current_community)
end

Given /^that transaction type shows the price of listing per (day)$/ do |price_per|
  @transaction_type.price_per = price_per
  @transaction_type.save!
end

Given /^that transaction uses payment preauthorization$/ do
  @transaction_type.update_attribute(:preauthorize_payment, true)
end

Given /^that transaction does not use payment preauthorization$/ do
  @transaction_type.update_attribute(:preauthorize_payment, false)
end

Given /^that transaction belongs to category "(.*?)"$/ do |category_name|
  category = find_category_by_name(category_name)
  category.transaction_types << @transaction_type
  category.save!
end

Given /^listing publishing date is shown in community "(.*?)"$/ do |community_domain|
  Community.find_by_domain(community_domain).update_attributes({:show_listing_publishing_date => true})
end

Given /^current community requires users to be verified to post listings$/ do
  @current_community.update_attribute(:require_verification_to_post_listings, true)
end

Given(/^this community has price filter enabled with min value (\d+) and max value (\d+)$/) do |min, max|
  @current_community.show_price_filter = true
  @current_community.price_filter_min = min.to_i * 100 # Cents
  @current_community.price_filter_max = max.to_i * 100 # Cents
  @current_community.save!
end

Given /^current community has (free|starter|basic|growth|scale) plan$/ do |plan|
  case plan
  when "free"
    plan_level = 0
  when "starter"
    plan_level = 1
  when "basic"
    plan_level = 2
  when "growth"
    plan_level = 3
  when "scale"
    plan_level = 4
  end
  @current_community.update_attribute(:plan_level, plan_level)
end

When /^community updates get delivered$/ do
  CommunityMailer.deliver_community_updates
end

Given(/^this community does not send automatic newsletters$/) do
  @current_community.update_attribute(:automatic_newsletters, false)
end

Given(/^community emails are sent from "(.*?)"$/) do |email|
  @current_community.update_attribute(:custom_email_from_address, email)
end
