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
PersonComment.all.each do |comment|
  unless comment.grade
    comment.update_attribute(:grade, 0.5)
  end
end
KassiEvent.all.each do |kassi_event|
  if kassi_event.person_comments.size < 1
    kassi_event.update_attribute(:pending, 1)
  end
end
Listing.update_all("visibility = 'communities'", "visibility LIKE 'kassi_users'")
Notification.all.each do |notification|
  if notification.badge_id
    notification.update_attribute(:notifiable_id, notification.badge_id)
    notification.update_attribute(:notifiable_type, "Badge")
  elsif notification.testimonial_id
    notification.update_attribute(:notifiable_id, notification.testimonial_id)
    notification.update_attribute(:notifiable_type, "Testimonial")
  end
end
Statistic.all.each do |s|
  j = JSON.parse(s.extra_data)
  if j["mau_g1"]
    s.mau_g1_count = j["mau_g1"]
  end
  if j["wau_g1"]
    s.wau_g1_count = j["wau_g1"]
  end
  s.save
end