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

  factory :person, aliases: [:author] do |p|
    p.id "dMF4WsJ7Kr3BN6ab9B7ckF"
    p.is_admin 0
    p.locale "en"
    p.test_group_number 4
    p.confirmed_at Time.now
    p.given_name "Proto"
    p.family_name "Testro"
    p.phone_number "0000-123456"
    p.username { |u| u.username = generate(:username) }
    p.password "testi"
    p.email { |e| e.email = generate(:email) }
  end  

  factory :share_type do |s|
    s.name "borrow"
  end  

  factory :listing do |l|
    l.title "Sledgehammer"
    l.description("test")
    l.author
    l.listing_type "request"
    l.category "item"
    l.share_type "buy"
    l.tag_list("tools, hammers")
    l.valid_until 3.months.from_now
    l.times_viewed 0
    l.visibility "everybody"
    l.communities { [ FactoryGirl.create(:community) ] }
  end

  factory :conversation do |c|
    c.title "Item offer: Sledgehammer"
    c.listing
    c.status "pending"
  end

  factory :message do |m|
    m.content "Test"
    m.association :conversation
    m.sender { |sender| sender.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  end

  factory :participation do |p|
    p.association :conversation
    p.association :person
    p.is_read false
    p.last_sent_at DateTime.now
  end

  factory :testimonial do |t|
    t.author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    t.association :participation
    t.grade 0.5
    t.text "Test text"
  end

  factory :comment do |c|
    c.author { |author| author.association(:person) }
    c.association :listing
    c.content "Test text"
  end

  factory :feedback do |f|
    f.author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    f.content "Test feedback"
    f.url "/requests"
    f.email "kassi_testperson1@example.com"
    f.is_handled 0
  end

  factory :badge do |b|
    b.person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    b.name "rookie"
  end

  factory :notification do |n|
    n.receiver { |receiver| receiver.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
    n.is_read 0
    n.notifiable_type "Listing"
    n.notifiable_id "1"
    n.description "to_own_listing"
  end

  factory :community do |c|
    c.name { |d| d.domain = FactoryGirl.next(:domain) }
    c.domain { |d| d.domain = FactoryGirl.next(:domain) }
    c.slogan "Test slogan"
    c.description "Test description"
    c.category "other"
  end

  factory :community_membership do |c|
    c.association :community
    c.association :person
    c.admin false
    c.consent "test_consent0.1"
  end

  factory :contact_request do |c|
    c.email "test@example.com"
  end

  factory :invitation do |c|
    c.community_id 1
  end

  factory :news_item do |n|
    n.title "A new event in our community"
    n.content "More information about this amazing event."
    n.author { |author| author.association(:person) }
  end  

  factory :device do |d|
    d.device_type "iPhone"
    d.device_token "LSIDFSLDJIOGSSCSBEUS52349583"
    d.person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  end

  factory :location do |c|
    c.association :listing
    c.association :person
    c.association :community
    c.latitude 62.2426
    c.longitude 25.7475
    c.address "helsinki"
    c.google_address "Helsinki, Finland"
  end
end
