Factory.define :person do |p|
  p.id "dMF4WsJ7Kr3BN6ab9B7ckF"
  p.is_admin 1
  p.locale "en"
  p.test_group_number 4
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
  l.share_types { |st| [st.association(:share_type), st.association(:share_type, :name => "buy")] }
  l.tag_list("tools, hammers")
  l.valid_until 3.months.from_now
  l.times_viewed 0
  l.visibility "everybody"
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
end

Factory.define :badge_notification do |b|
  b.receiver { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  b.is_read 0
  b.association :badge
end

Factory.define :testimonial_notification do |b|
  b.receiver { |person| person.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  b.is_read 0
  b.association :testimonial
end

Factory.define :community do |c|
  c.name "Test"
  c.domain "test"
end

Factory.define :community_membership do |c|
  c.association :community
  c.association :person
  c.admin false
end

Factory.define :contact_request do |c|
  c.email "test@example.com"
end

Factory.define :invitation do |c|
  c.community_id 1
end