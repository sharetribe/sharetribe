Listing.find(:all).each { |listing| listing.update_attribute :last_modified, listing.created_at}
Person.find(:all).each do |person|
  person.settings = Settings.create
end
KassiEvent.all.each do |event|
  event.people.each do |person|
    if event.realizer_id == person.id
      role = "provider"
    elsif event.receiver_id == person.id
      role = "requester"
    else
      role = "none"
    end
    KassiEventParticipation.create(:person_id => person.id,
                                   :kassi_event_id => event.id,
                                   :role => role)
  end
end