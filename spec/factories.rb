# FactoryGirl definitions
#
# Notes:
# - The caller is responsible for deciding whether the object should or should not be persisted to the DB, thus...
# - Factories should NEVER write anything to database if .build is used. So when building associations,
#   make sure they are not written to DB.

require "#{Rails.root}/test/helper_modules"

class FactoryGirl::DefinitionProxy

  # has_many is a neat helper that can be used to eliminate quirky before/after books for
  # creating associations.
  #
  # Credits: https://gist.github.com/ybart/8844969
  #
  # Usage: ctrl+f "has_many"
  #
  def has_many(collection, count = 1)
    # after_build is where you add instances to the factory-built collection.
    # Typically you'll want to Factory.build() these instances.
    after (:build) do |instance, evaluator|
      if instance.send(collection).blank?
        count.times { instance.send(collection) << yield(instance, evaluator) } if instance.send(collection).empty?
      end
    end

    # after_create will be called after after_build if the build strategy is Factory.create()
    after(:create) do |instance|
      instance.send(collection).each { |i| i.save! }
    end
  end

  # Use build_associations to build `has_one` associations.
  #
  # Usage:
  #
  # factory :listing do
  #   title "Cool surfboard"
  #   build_association(:author)
  # end
  #
  # factory :category_custom_field do
  #   build_association(:custom_dropdown_field, as: :custom_field)
  # end
  #
  # By default, FactoryGirl saves associations to the database and we don't want that.
  #
  def build_association(association, opts = {})
    as = opts.fetch(:as) { association }
    self.send(as) { |instance| instance.association(association, strategy: :build) }
  end
end

FactoryGirl.define do
  sequence :id do |_|
    UUID.timestamp_create.to_s22
  end

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
    id
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

  factory :transaction do
    build_association(:person, as: :starter)
    build_association(:listing)
    build_association(:community)
  end

  factory :conversation do
    title "Item offer: Sledgehammer"
    build_association(:community)

    has_many(:messages, 0) do |conversation|
      FactoryGirl.build(:message, conversation: conversation)
    end

    created_at DateTime.now
    updated_at DateTime.now
  end

  factory :booking do
    build_association(:transaction)
    start_on 1.day.from_now
    end_on 2.days.from_now
  end

  factory :message do
    content "Test"
    build_association(:conversation)
    build_association(:sender)
  end

  factory :participation do
    build_association(:conversation)
    build_association(:person)
    is_read false
    last_sent_at DateTime.now
  end

  factory :testimonial do
    build_association(:author)
    build_association(:receiver)
    build_association(:transaction)
    grade 0.5
    text "Test text"
  end

  factory :comment do
    build_association(:author)
    build_association(:listing)
    content "Test text"
  end

  factory :feedback do
    build_association(:author)
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

    has_many(:community_customizations) do |community|
      FactoryGirl.build(:community_customization, community: community)
    end
  end

  factory :community_customization do
    build_association(:community)
    name "Sharetribe"
    locale "en"
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
    build_association(:person)
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

    ['Sell', 'Give', 'Lend', 'Rent', 'Request', 'Service'].each do |type|
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
    build_association(:community)

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
    has_many :titles do
      FactoryGirl.build(:custom_field_option_title)
    end
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
    build_association(:transaction)
  end

  factory :payment do
    build_association(:community)
    build_association(:transaction)

    factory :braintree_payment, class: 'BraintreePayment' do
      build_association(:payer)
      build_association(:recipient)
      status "pending"
      payment_gateway { FactoryGirl.build(:braintree_payment_gateway) }
      currency "USD"
      sum_cents 500
    end

    factory :checkout_payment, class: 'CheckoutPayment' do
      build_association(:payer)
      build_association(:recipient)
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
    build_association(:person)
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
    build_association(:community)
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
    build_association(:community)
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
    build_association(:person)
    build_association(:follower)
  end
end
