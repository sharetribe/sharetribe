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
    SecureRandom.urlsafe_base64
  end

  sequence :uuid do
    UUIDUtils.create_raw
  end

  sequence :username do |n|
    "kassi_tester#{n}"
  end

  sequence :email_address do |n|
    "kassi_tester#{n}@example.com"
  end

  sequence :ident do |n|
    "sharetribe-testcommunity-#{n}"
  end

  sequence :token do |n|
    "token-#{n}"
  end

  factory :auth_token do
    build_association(:person)
    expires_at 30.days.from_now
    token
    token_type "unsubscribe"
  end

  factory :person, aliases: [:author, :receiver, :recipient, :payer, :sender, :follower] do
    transient do
      member_of nil
      member_is_admin false
    end

    id
    is_admin 0
    community_id 1
    locale "en"
    test_group_number 4
    given_name "Proto"
    family_name "Testro"
    phone_number "0000-123456"
    username
    password "testi"

    has_many :emails do |person|
      FactoryGirl.build(:email, person: person)
    end

    after(:create) do |person, evaluator|
      if evaluator.member_of
        person.create_community_membership(community: evaluator.member_of,
                                           admin: evaluator.member_is_admin)
      end
    end
  end

  factory :listing do
    community_id 999
    title "Sledgehammer"
    description("test")
    build_association(:author)
    category { TestHelpers::find_or_build_category("item") }
    valid_until { Time.current + 3.months }
    times_viewed 0
    privacy "public"
    listing_shape_id 123
    price Money.new(20, "USD")
    uuid
  end

  factory :transaction do
    build_association(:person, as: :starter)
    build_association(:community)
    build_association(:listing)
    listing_title { listing.title }
    listing_author_id { listing.author.id }
    unit_price { listing.price }
    commission_from_seller 0
    automatic_confirmation_after_days 14
    listing_quantity 1
    listing_uuid { listing.uuid } # raw UUID
    community_uuid { community.uuid } # raw UUID
    starter_uuid { starter.uuid } # raw UUID
    listing_author_uuid { listing.author.uuid } # raw UUID
    payment_process :none
    delivery_method "none"
    payment_gateway :none
    availability "none"
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
    build_association(:transaction, as: :tx)
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
    build_association(:transaction, as: :tx)
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
    ident
    slogan "Test slogan"
    description "Test description"
    currency "EUR"
    build_association(:marketplace_configurations, as: :configuration)

    has_many(:community_customizations) do |community|
      FactoryGirl.build(:community_customization, community: community)
    end

    uuid
  end

  factory :community_customization do
    build_association(:community)
    name "Sharetribe"
    locale "en"
    slogan "Test slogan"
    description "Test description"
  end

  factory :community_membership do
    build_association(:community)
    build_association(:person)
    admin false
    consent "test_consent0.1"
    status "accepted"
  end

  factory :marketplace_configurations do
    community_id 1
    main_search "keyword"
    distance_unit "metric"
    limit_search_distance 0
    limit_priority_links nil
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
    community_id 1
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

  factory :custom_field, aliases: [:question] do
    build_association(:community)

    has_many :category_custom_fields do |custom_field|
      FactoryGirl.build(:category_custom_field, :custom_field => custom_field)
    end

    has_many :names do |custom_field|
      FactoryGirl.build(:custom_field_name)
    end

    factory :custom_dropdown_field, class: 'DropdownField' do
      search_filter true

      has_many :options do |custom_field|
        [FactoryGirl.build(:custom_field_option), FactoryGirl.build(:custom_field_option)]
      end
    end

    factory :custom_text_field, class: 'TextField' do
    end

    factory :custom_numeric_field, class: 'NumericField' do
      min 0
      max 100
      search_filter true
    end

    factory :custom_checkbox_field, class: 'CheckboxField' do
      search_filter true

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
    sequence(:value) { |n| "Test option #{n}" }
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

  factory :person_custom_field, parent: :custom_field do
    entity_type :for_person

    has_many :category_custom_fields do |custom_field|
    end

    factory :person_custom_dropdown_field, class: 'DropdownField' do
      has_many :options do |custom_field|
        [FactoryGirl.build(:custom_field_option), FactoryGirl.build(:custom_field_option)]
      end
    end

    factory :person_custom_text_field, class: 'TextField'

    factory :person_custom_numeric_field, class: 'NumericField' do
      min 0
      max 100
    end

    factory :person_custom_checkbox_field, class: 'CheckboxField' do
      has_many :options do |custom_field|
        [FactoryGirl.build(:custom_field_option), FactoryGirl.build(:custom_field_option)]
      end
    end

    factory :person_custom_date_field, class: 'DateField'
  end

  factory :transaction_transition do
    to_state "not_started"
    build_association(:transaction, as: :tx)
  end

  factory :menu_link do
    build_association(:community)
  end

  factory :menu_link_translation do
    title "Blog"
    url "http://blog.sharetribe.com"
    locale "en"
  end

  factory :follower_relationship do
    build_association(:person)
    build_association(:follower)
  end

  factory :marketplace_sender_email do
    name 'Edna'
    email 'edna@mail.com'
  end

  factory :transaction_process do
    community_id     1
    process          'preauthorize'
    author_is_seller true
  end

  factory :payment_settings do
    community_id                      1
    active                            true
    payment_gateway                   'paypal'
    payment_process                   'preauthorize'
    commission_from_seller            11
    minimum_price_cents               100
    minimum_price_currency            'EUR'
    minimum_transaction_fee_cents     10
    minimum_transaction_fee_currency  'EUR'
    confirmation_after_days           14
  end

  factory :order_permission do
    request_token       'ABC'
    paypal_username_to  'mildred@example.com'
    scope               "EXPRESS_CHECKOUT,REFUND,AUTH_CAPTURE,TRANSACTION_DETAILS,REFERENCE_TRANSACTION,RECURRING_PAYMENTS,SETTLEMENT_REPORTING,RECURRING_PAYMENT_REPORT,ACCESS_BASIC_PERSONAL_DATA"
    verification_code   'DEF'
    build_association(:paypal_account)
  end

  factory :paypal_account do
    person_id nil
    community_id 123
    email 'mildred@example.com'
    payer_id 'ABC'
    active true
  end

  factory :listing_shape do
    community_id           123
    transaction_process_id 1
    price_enabled          false
    shipping_enabled       false
    name                   'Selling'
    name_tr_key            'unit.day'
    action_button_tr_key   'unit.days'
    sort_priority          0
  end

  factory :listing_unit do
    unit_type           'hour'
    quantity_selector   'number'
    kind                'time'
    name_tr_key         nil
    selector_tr_key     nil
    listing_shape_id    123
  end

  factory :invitation_unsubscribe, class: 'Invitation::Unsubscribe' do
    build_association(:community)
    email 'sherry@example.com'
  end

  factory :paypal_ipn_message do
    body       { { abc: 123 } }
    status     nil
  end

  factory :paypal_payment do
    community_id      123
    transaction_id    321
    payer_id          'ABC'
    receiver_id       'DEF'
    merchant_id       'ZZZ'
    currency          'EUR'
    payment_status    'pending'
    commission_status 'pending'
  end

  factory :listing_working_time_slot, class: 'Listing::WorkingTimeSlot' do
    listing_id 123
  end

  factory :billing_agreement do
    build_association(:paypal_account)
    billing_agreement_id  'zzz'
    paypal_username_to    'eloise.smith'
    request_token         'ddd'
  end

  factory :stripe_payment do
    community_id      123
    transaction_id    321
    payer_id          "AAA"
    receiver_id       "BBB"
    status            "paid"
    sum_cents         200
    commission_cents  100
    currency          "EUR"
    stripe_charge_id  "CCC"
    stripe_transfer_id nil
    fee_cents         0
    real_fee_cents    31
    subtotal_cents    200
  end

  factory :stripe_account do
    community_id      123
    person_id         "ABC"
  end
end
