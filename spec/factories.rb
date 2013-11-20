FactoryGirl.define do
  sequence :username do |n|
    "kassi_tester#{n}"
  end

  sequence :email_address do |n|
    "kassi_tester#{n}@example.com"
  end

  sequence :domain do |n|
    "sharetribe_testcommunity_#{n}" 
  end
  
  sequence :organization_name do |n|
    "test_organization#{n}" 
  end
  

  factory :person, aliases: [:author, :receiver, :recipient, :payer] do
    is_admin 0
    locale "en"
    test_group_number 4
    confirmed_at Time.now
    given_name "Proto"
    family_name "Testro"
    phone_number "0000-123456"
    username
    email "fake_email_because@devise.needs.it"
    password "testi"
    is_organization false

    after(:create) do |person|
      FactoryGirl.create_list(:email, 1, person: person)
    end
  end  

  factory :listing do
    title "Sledgehammer"
    description("test")
    author
    category {find_or_create_category("item")}
    share_type {find_or_create_share_type("sell")}
    tag_list("tools, hammers")
    valid_until 3.months.from_now
    times_viewed 0
    visibility "this_community"
    privacy "private"
    communities { [ FactoryGirl.create(:community) ] }
  end

  factory :conversation do
    title "Item offer: Sledgehammer"
    listing
    status "pending"
  end

  factory :message do
    content "Test"
    association :conversation
    sender { |sender| sender.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  end

  factory :participation do
    association :conversation
    association :person
    is_read false
    last_sent_at DateTime.now
  end

  factory :testimonial do
    author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
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
    author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    content "Test feedback"
    url "/requests"
    email "kassi_testperson1@example.com"
    is_handled 0
  end

  factory :badge do
    person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    name "rookie"
  end

  factory :notification do
    receiver
    is_read 0
    notifiable_type "Listing"
    notifiable_id "1"
    description "to_own_listing"
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
  end

  factory :invitation do
    community_id 1
  end

  factory :news_item do
    title "A new event in our community"
    content "More information about this amazing event."
    author { |author| author.association(:person) }
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
  
  factory :email, class: Email do
    person
    address { generate(:email_address) }
    confirmed_at Time.now
  end
  
  factory :category do
    name "item"
    icon "item"
  end
  
  factory :share_type do
    name "sell"
    icon "sell"
  end
  
  factory :organization do
    name { generate(:organization_name) }
    company_id "1234567-8"
    merchant_id "375917"
    merchant_key "SAIPPUAKAUPPIAS"
  end
  
  factory :payment do
    payer
    recipient
  end
end
