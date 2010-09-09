Factory.define :person do |p|
  p.id "dMF4WsJ7Kr3BN6ab9B7ckF"
  p.is_admin 1
  p.locale "en"
end  

Factory.define :share_type do |s|
  s.name "borrow"
end  

Factory.define :listing do |l|
  l.title "Sledgehammer"
  l.description("Test" * 1000)
  l.author { |author| author.association(:person) }
  l.listing_type "request"
  l.category "item"
  l.share_types { |st| [st.association(:share_type), st.association(:share_type, :name => "buy")] }
  l.tag_list("tools, hammers")
  l.valid_until DateTime.now + 3.months
end

Factory.define :conversation do |c|
  c.title "Item request: Sledgehammer"
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
  c.author { |author| author.association(:person, :id => get_test_person_and_session("kassi_testperson1")[0].id) }
  c.association :listing
  c.content "Test text"
end