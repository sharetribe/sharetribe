require "#{Rails.root}/test/helper_modules"

class FactoryGirl::DefinitionProxy

  # has_many is a neat helper that can be used to eliminate quirky before/after books for
  # creating associations.
  #
  # Credits: https://gist.github.com/ybart/8844969
  #
  # Usage: ctrl+f "has_many"
  #
  def has_many(collection)
    # after_build is where you add instances to the factory-built collection.
    # Typically you'll want to Factory.build() these instances.
    after (:build) do |instance, evaluator|
      instance.send(collection) << yield(instance, evaluator) if instance.send(collection).empty?
    end

    # after_create will be called after after_build if the build strategy is Factory.create()
    after(:create) do |instance|
      instance.send(collection).each { |i| i.save! }
    end
  end

  def build_association(association, opts = {})
    as = opts.fetch(:as) { association }
    self.send(as) { |instance| instance.association(association, strategy: :build) }
  end
end

FactoryGirl.define do
  sequence :username do |n|
    "kassi_tester#{n}"
  end

  sequence :email_address do |n|
    "kassi_tester#{n}@example.com"
  end

  sequence :domain do |n|
    "sharetribe-testcommunity-#{n}"
  end

  factory :person, aliases: [:author, :receiver, :recipient, :payer, :sender, :follower] do
    is_admin 0
    locale "en"
    test_group_number 4
    given_name "Proto"
    family_name "Testro"
    phone_number "0000-123456"
    username
    password "testi"
    is_organization false

    has_many :emails do |person|
      FactoryGirl.build(:email, person: person)
    end
  end

  factory :listing do
    title "Sledgehammer"
    description("test")
    build_association(:author)
    category { TestHelpers::find_or_build_category("item") }
    build_association(:transaction_type_sell, as: :transaction_type)
    valid_until 3.months.from_now
    times_viewed 0
    visibility "this_community"
    privacy "public"

    has_many :communities do |listing|
      FactoryGirl.build(:community)
    end
  end

  factory :conversation do
    title "Item offer: Sledgehammer"
    community

    factory :listing_conversation, class: 'ListingConversation' do
      listing { |listing_conversation| listing_conversation.association(:listing, strategy: :build) }
    end
  end

  factory :message do
    content "Test"
    build_association(:conversation)
    sender
  end

  factory :participation do
    build_association(:conversation)
    build_association(:person)
    is_read false
    last_sent_at DateTime.now
  end

  factory :testimonial do
    author
    build_association(:participation)
    grade 0.5
    text "Test text"
  end

  factory :comment do
    build_association(:author)
    build_association(:listing)
    content "Test text"
  end

  factory :feedback do
    author
    content "Test feedback"
    url "/requests"
    email "kassi_testperson1@example.com"
    is_handled 0
  end

  factory :community do
    name { generate(:domain) }
    domain
    slogan "Test slogan"
    description "Test description"
    category "other"
  end

  factory :community_membership do
    build_association(:community)
    build_association(:person)
    admin false
    consent "test_consent0.1"
    status "accepted"
  end

  factory :contact_request do
    email "test@example.com"
    country "AO"
    marketplace_type "Service marketplace"
  end

  factory :invitation do
    community_id 1
  end

  factory :location do
    build_association(:listing)
    build_association(:person)
    build_association(:community)
    latitude 62.2426
    longitude 25.7475
    address "helsinki"
    google_address "Helsinki, Finland"
  end

  factory :email do
    person
    address { generate(:email_address) }
    confirmed_at Time.now
    send_notifications true
  end

  factory :category do
    icon "item"
    build_association(:community)
  end

  factory :category_translation do
    name "test category"
    locale "en"
  end

  factory :transaction_type_translation do
    name "Selling"
    locale "en"
    build_association(:transaction_type)
  end

  factory :transaction_type do
    build_association(:community)

    ['Sell', 'Give', 'Lend', 'Request', 'Service'].each do |type|
      factory_name = "transaction_type_#{type.downcase}"
      factory factory_name.to_sym, class: type do
        type type
        has_many :translations do |transaction_type|
          FactoryGirl.build(:transaction_type_translation, :name => type, :transaction_type => transaction_type)
        end
      end
    end
  end

  factory :custom_field, aliases: [:question] do
    community

    has_many :category_custom_fields do |custom_field|
      FactoryGirl.build(:category_custom_field, :custom_field => custom_field)
    end

    has_many :names do |custom_field|
      FactoryGirl.build(:custom_field_name)
    end

    factory :custom_dropdown_field, class: 'DropdownField' do
      has_many :options do |custom_field|
        [FactoryGirl.build(:custom_field_option), FactoryGirl.build(:custom_field_option)]
      end
    end

    factory :custom_text_field, class: 'TextField' do
    end

    factory :custom_numeric_field, class: 'NumericField' do
      min 0
      max 100
    end

    factory :custom_checkbox_field, class: 'CheckboxField' do
      has_many :options do |custom_field|
        [FactoryGirl.build(:custom_field_option), FactoryGirl.build(:custom_field_option)]
      end
    end

    factory :custom_date_field, class: 'DateField' do
    end

  end

  factory :category_custom_field do
    build_association(:category)
    build_association(:custom_dropdown_field, as: :custom_field)
  end

  factory :custom_field_option do
    titles { [ FactoryGirl.build(:custom_field_option_title) ] }
  end

  factory :custom_field_option_selection do
    build_association(:custom_field_value)
    build_association(:custom_field_option)
  end

  factory :custom_field_option_title do
    value "Test option"
    locale "en"
  end

  factory :custom_field_name do
    value "Test field"
    locale "en"
  end

  factory :custom_field_value do
    build_association(:question)
    build_association(:listing)

    factory :dropdown_field_value, class: 'DropdownFieldValue' do
      build_association(:custom_dropdown_field, as: :question)

      has_many :custom_field_option_selections do |dropdown_field_value|
        FactoryGirl.build(:custom_field_option_selection, custom_field_value: dropdown_field_value)
      end
    end

    factory :checkbox_field_value, class: 'CheckboxFieldValue' do
      build_association(:custom_checkbox_field, as: :question)
    end

    factory :custom_numeric_field_value, class: 'NumericFieldValue' do
      build_association(:custom_numeric_field, as: :question)
      numeric_value 0
    end
  end

  factory :transaction_transition do
    to_state "not_started"
  end

  factory :payment do
    community

    factory :braintree_payment, class: 'BraintreePayment' do
      payer
      recipient
      status "pending"
      payment_gateway { FactoryGirl.build(:braintree_payment_gateway) }
      currency "USD"
      sum_cents 500
    end

    factory :checkout_payment, class: 'CheckoutPayment' do
      payer
      recipient
      status "pending"
      payment_gateway { FactoryGirl.build(:checkout_payment_gateway) }
      currency "EUR"

      has_many :rows do
        FactoryGirl.build(:payment_row)
      end
    end
  end

  factory :payment_row do
    currency "EUR"
    sum_cents 2000
  end

  factory :braintree_account do
    person
    first_name "Joe"
    last_name "Bloggs"
    email "joe@14ladders.com"
    phone "5551112222"
    address_street_address "123 Credibility St."
    address_postal_code "60606"
    address_locality "Chicago"
    address_region "IL"
    date_of_birth "1980-10-09"
    routing_number "1234567890"
    hidden_account_number "*********98"
    status "active"
    community
  end

  factory :payment_gateway do
    factory :braintree_payment_gateway, class: 'BraintreePaymentGateway' do
      braintree_merchant_id { APP_CONFIG.braintree_test_merchant_id }
      braintree_master_merchant_id { APP_CONFIG.braintree_test_master_merchant_id }
      braintree_public_key { APP_CONFIG.braintree_test_public_key }
      braintree_private_key { APP_CONFIG.braintree_test_private_key }
      braintree_client_side_encryption_key { APP_CONFIG.braintree_client_side_encryption_key }
      braintree_environment { APP_CONFIG.braintree_environment }
    end

    factory :checkout_payment_gateway, class: 'Checkout' do
      checkout_environment "stub"
    end
  end

  factory :menu_link do
    community
  end

  factory :menu_link_translation do
    title "Blog"
    url "http://blog.sharetribe.com"
    locale "en"
  end

  factory :country_manager do
    given_name "Country Manager Given Name"
    family_name "Country Manager Family Name"
    email "global@manager.com"
    country "global"
    subject_line "This subject will see requester"
    email_content "This email will get the requester"
  end

  factory :follower_relationship do
    person
    follower
  end
end
