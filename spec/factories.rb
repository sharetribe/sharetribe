FactoryGirl.define do
  sequence :username do |n|
    "kassi_tester#{n}" 
  end

  sequence :email do |n|
    "kassi_tester#{n}@example.com" 
  end

  sequence :domain do |n|
    "sharetribe_testcommunity_#{n}" 
  end

  factory :person, aliases: [:author, :receiver] do
    id "dMF4WsJ7Kr3BN6ab9B7ckF"
    is_admin 0
    locale "en"
    test_group_number 4
    confirmed_at Time.now
    given_name "Proto"
    family_name "Testro"
    phone_number "0000-123456"
    username
    password "testi"
    email
  end  

  factory :share_type do
    name "borrow"
  end  

  factory :listing do
    title "Sledgehammer"
    description("test")
    author
    listing_type "request"
    category "item"
    share_type "buy"
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
end
