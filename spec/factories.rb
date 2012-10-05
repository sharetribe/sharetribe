Factory.sequence :username do |n|
  "kassi_tester#{n}" 
end

Factory.sequence :email do |n|
  "kassi_tester#{n}@example.com" 
end

Factory.sequence :domain do |n|
  "sharetribe_testcommunity_#{n}" 
end


Factory.define :person do |p|
  p.id "dMF4WsJ7Kr3BN6ab9B7ckF"
  p.is_admin 0
  p.locale "en"
  p.test_group_number 4
  p.confirmed_at Time.now
  p.given_name "Proto"
  p.family_name "Testro"
  p.phone_number "0000-123456"
  if not ApplicationHelper::use_asi?
    p.username { |u| u.username = Factory.next(:username) }
    p.password "testi"
    p.email { |e| e.email = Factory.next(:email) }
  end
end  

Factory.define :share_type do |s|
  s.name "borrow"
end  

Factory.define :listing do |l|
  l.title "Sledgehammer"
  l.description("test")
  l.author { |author| author.association(:person) }
  l.listing_type "request"
  l.category "item"
  l.share_type "buy"
  l.tag_list("tools, hammers")
  l.valid_until 3.months.from_now
  l.times_viewed 0
  l.visibility "this_community"
  l.privacy "private"
  l.communities { [ Factory.create(:community) ] }
end

Factory.define :conversation do |c|
  c.title "Item offer: Sledgehammer"
  c.association :listing
  c.status "pending"
end

Factory.define :message do |m|
  m.content "Test"
  m.association :conversation
  m.sender { |sender| sender.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
end

Factory.define :participation do |p|
  p.association :conversation
  p.association :person
  p.is_read false
  p.last_sent_at DateTime.now
end

Factory.define :testimonial do |t|
  t.author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  t.association :participation
  t.grade 0.5
  t.text "Test text"
end

Factory.define :comment do |c|
  c.author { |author| author.association(:person) }
  c.association :listing
  c.content "Test text"
end

Factory.define :feedback do |f|
  f.author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  f.content "Test feedback"
  f.url "/requests"
  f.email "kassi_testperson1@example.com"
  f.is_handled 0
end

Factory.define :badge do |b|
  b.person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  b.name "rookie"
end

Factory.define :notification do |n|
  n.receiver { |receiver| receiver.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  n.is_read 0
  n.notifiable_type "Listing"
  n.notifiable_id "1"
  n.description "to_own_listing"
end

Factory.define :community do |c|
  c.name { |d| d.domain = Factory.next(:domain) }
  c.domain { |d| d.domain = Factory.next(:domain) }
  c.slogan "Test slogan"
  c.description "Test description"
  c.category "other"
end

Factory.define :community_membership do |c|
  c.association :community
  c.association :person
  c.admin false
  c.consent "test_consent0.1"
end

Factory.define :contact_request do |c|
  c.email "test@example.com"
end

Factory.define :invitation do |c|
  c.community_id 1
end

Factory.define :news_item do |n|
  n.title "A new event in our community"
  n.content "More information about this amazing event."
  n.author { |author| author.association(:person) }
end  

Factory.define :device do |d|
  d.device_type "iPhone"
  d.device_token "LSIDFSLDJIOGSSCSBEUS52349583"
  d.person { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
end

Factory.define :location do |c|
  c.association :listing
  c.association :person
  c.association :community
  c.latitude 62.2426
  c.longitude 25.7475
  c.address "helsinki"
  c.google_address "Helsinki, Finland"
end
