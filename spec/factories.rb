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
    author
    category { find_or_build_category("item") }
    transaction_type { FactoryGirl.build(:transaction_type_sell) }
    tag_list("tools, hammers")
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
      listing
    end
  end

  factory :message do
    content "Test"
    association :conversation
    sender
  end

  factory :participation do
    association :conversation
    association :person
    is_read false
    last_sent_at DateTime.now
  end

  factory :testimonial do
    author
    association :participation
    grade 0.5
    text "Test text"
  end

  factory :comment do
    author { |author| author.association(:person) }
    association :listing
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
    association :community
    association :person
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

  factory :device do
    device_type "iPhone"
    device_token "LSIDFSLDJIOGSSCSBEUS52349583"
    person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  end

  factory :location do
    association :listing
    association :person
    association :community
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
    association :community
  end

  factory :category_translation do
    name "test category"
    locale "en"
  end

  factory :transaction_type_translation do
    name "Selling"
    locale "en"
  end

  factory :transaction_type do
    association :community

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
    category
    custom_field :custom_dropdown_field
  end

  factory :custom_field_option do
    titles { [ FactoryGirl.build(:custom_field_option_title) ] }
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
    question
    listing
  end

  factory :dropdown_field_value, class: 'DropdownFieldValue' do
    question { [ FactoryGirl.build(:custom_dropdown_field) ] }
    listing
  end

  factory :checkbox_field_value, class: 'CheckboxFieldValue' do
    question { [ FactoryGirl.build(:custom_checkbox_field) ] }
    listing
  end

  factory :custom_numeric_field_value, class: 'NumericFieldValue' do
    question { [ FactoryGirl.build(:custom_numeric_field) ] }
    listing
    numeric_value 0
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
    end

    factory :checkout_payment, class: 'CheckoutPayment' do
      payer
      recipient
      status "pending"
      payment_gateway { FactoryGirl.build(:checkout_payment_gateway) }
      currency "EUR"
    end
  end

  factory :payment_row do
    currency "EUR"
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
