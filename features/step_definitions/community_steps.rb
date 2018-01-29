module CommunitySteps

  def save_name_and_action(community_id, groups)
    created_translations = TranslationService::API::Api.translations.create(community_id, groups)
    created_translations[:data].map { |translation| translation[:translation_key] }
  end
end

World(CommunitySteps)

Given /^there are following communities:$/ do |communities_table|
  communities_table.hashes.each do |hash|
    ident = hash[:community]
    existing_community = Community.where(ident: ident).first
    existing_community.destroy if existing_community
    @hash_community = FactoryGirl.create(:community, :ident => ident, :settings => {"locales" => ["en", "fi"]})

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
  Community.where(ident: community).first.update_attribute(:consent, terms)
end

Then /^Most recently created user should be member of "([^"]*)" community with(?: status "(.*?)" and)? its latest consent accepted(?: with invitation code "([^"]*)")?$/ do |community_ident, status, invitation_code|
    # Person.last seemed to return unreliable results for some reason
    # (kassi_testperson1 instead of the actual newest person, so changed
    # to look for the latest CommunityMembership)
    status ||= "accepted"

    community = Community.where(ident: community_ident).first
    expect(CommunityMembership.last.community).to eq(community)
    expect(CommunityMembership.last.consent).to eq(community.consent)
    expect(CommunityMembership.last.status).to eq(status)
    expect(CommunityMembership.last.invitation.code).to eq(invitation_code) if invitation_code.present?
end

Given /^given name and last name are not required in community "([^"]*)"$/ do |community|
  Community.where(ident: community).first.update_attribute(:real_name_required, 0)
end

Given /^community "([^"]*)" requires invite to join$/ do |community|
  Community.where(ident: community).first.update_attribute(:join_with_invite_only, true)
end

Given /^community "([^"]*)" does not require invite to join$/ do |community|
  Community.where(ident: community).first.update_attribute(:join_with_invite_only, false)
end

Given /^users (can|can not) invite new users to join community "([^"]*)"$/ do |verb, community|
  can_invite = verb == "can"
  Community.where(ident: community).first.update_attribute(:users_can_invite_new_users, can_invite)
end

Given /^there is an invitation for community "([^"]*)" with code "([^"]*)"(?: with (\d+) usages left)?$/ do |community, code, usages_left|
  inv = Invitation.new(:community => Community.where(ident: community).first, :code => code, :inviter_id => @people.first[1].id)
  inv.usages_left = usages_left if usages_left.present?
  inv.save
end

Then /^Invitation with code "([^"]*)" should have (\d+) usages_left$/ do |code, usages|
  expect(Invitation.find_by_code(code).usages_left).to eq(usages.to_i)
end

When /^I move to community "([^"]*)"$/ do |community|
  Capybara.default_host = "http://#{community}.lvh.me:9887"
  Capybara.app_host = "http://#{community}.lvh.me:9887"
  @current_community = Community.where(ident: community).first
end

When /^I arrive to sign up page with the link in the invitation email with code "(.*?)"$/ do |code|
  visit "/en/signup?code=#{code}"
end

Given /^community "(.*?)" is private$/ do |community_ident|
  Community.where(ident: community_ident).first.update_attributes({:private => true})
end

Given /^this community is private$/ do
  @current_community.private = true
  @current_community.save!
end

Given /^community "(.*?)" has following category structure:$/ do |community, categories|
  current_community = Community.where(ident: community).first
  old_category_ids = current_community.categories.collect(&:id)

  current_community.categories = categories.hashes.map do |hash|
    category = current_community.categories.create!
    category.translations.create!(:name => hash['fi'], :locale => 'fi')
    category.translations.create!(:name => hash['en'], :locale => 'en')

    shape = category.community.shapes.first
    CategoryListingShape.create!(category_id: category.id, listing_shape_id: shape[:id])

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

Given /^community "(.*?)" has following listing shapes enabled:$/ do |community, listing_shapes|
  current_community = Community.where(ident: community).first
  ListingShape.where(community_id: current_community.id).destroy_all

  process_id = TransactionProcess.where(community_id: current_community.id, process: :none).first.id

  listing_shapes.hashes.map do |hash|
    name_tr_key, action_button_tr_key = save_name_and_action(current_community.id, [
      {translations: [ {locale: 'fi', translation: hash['fi']}, {locale: 'en', translation: hash['en']} ]},
      {translations: [ {locale: 'fi', translation: (hash['button'] || 'Action')}, {locale: 'en', translation: (hash['button'] || 'Action')} ]}
    ])

    ListingShape.create_with_opts(
      community: current_community,
      opts: {
        price_enabled: true,
        shipping_enabled: false,
        name_tr_key: name_tr_key,
        action_button_tr_key: action_button_tr_key,
        transaction_process_id: process_id,
        basename: hash['en'],
        units: [ {unit_type: 'hour', quantity_selector: 'number', kind: 'time'} ]
      }
    )
  end

  current_community.reload
end

Given /^listing publishing date is shown in community "(.*?)"$/ do |community_ident|
  Community.where(ident: community_ident).first.update_attributes({:show_listing_publishing_date => true})
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

When /^community updates get delivered$/ do
  CommunityMailer.deliver_community_updates
end

Given(/^this community does not send automatic newsletters$/) do
  @current_community.update_attribute(:automatic_newsletters, false)
end

Given(/^community emails are sent from name "(.*?)" and address "(.*?)"$/) do |name, email|
  EmailService::API::Api.addresses.create(
    community_id: @current_community.id,
    address: {
      name: name,
      email: email,
      verification_status: :verified
    }
  )
end

Given /^community "(.*?)" has country "(.*?)" and currency "(.*?)"$/ do |community, country, currency|
  community = Community.where(ident: community).first
  community.country = country
  community.currency = currency
  community.save
end

Given /^community "(.*?)" has payment method "(.*?)" provisioned$/ do |community, payment_gateway|
  community = Community.where(ident: community).first
  if payment_gateway
    TransactionService::API::Api.settings.provision(
      community_id: community.id,
      payment_gateway: payment_gateway,
      payment_process: :preauthorize,
      active: true)
  end
  if payment_gateway == 'stripe'
    FeatureFlagService::API::Api.features.enable(community_id: community.id, features: [:stripe])
  end
end

Given /^community "(.*?)" has payment method "(.*?)" enabled by admin$/ do |community, payment_gateway|
  community = Community.where(ident: community).first
  tx_settings_api = TransactionService::API::Api.settings
  if payment_gateway == 'paypal'
    FactoryGirl.create(:paypal_account,
                       community_id: community.id,
                       order_permission: FactoryGirl.build(:order_permission))
  end
  data = {
    community_id: community.id,
    payment_process: :preauthorize,
    payment_gateway: payment_gateway
  }
  tx_settings_api.activate(data)
  tx_settings_api.update(data.merge(
    commission_from_seller: 10,
    minimum_price_cents: 100
  ))
  if payment_gateway == 'stripe'
    tx_settings_api.update(data.merge(
      api_private_key: 'sk_test_123456789012345678901234',
      api_publishable_key: 'pk_test_123456789012345678901234'
    ))
    tx_settings_api.api_verified(data)
  end
end

Given /^this community has transaction agreement in use$/ do
  @current_community.transaction_agreement_in_use = true
  customization = @current_community.community_customizations.where(locale: 'en').first
  customization.update_columns(
    transaction_agreement_label: 'Transaction Agreement Label',
    transaction_agreement_content: 'Transaction Agreement Content'
  )
  @current_community.save!
end

Given /^community "(.*?)" has feature flag "(.*?)" enabled$/ do |community, feature_flag|
  community = Community.where(ident: community).first
  FeatureFlagService::API::Api.features.enable(community_id: community.id, features: [feature_flag.to_sym])
end
