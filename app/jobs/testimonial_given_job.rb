class TestimonialGivenJob < Struct.new(:testimonial_id, :host) 
  
  def perform
    testimonial = Testimonial.find(testimonial_id)
    testimonial.participation.update_attribute(:is_read, true)
    testimonial.notify_receiver(host)
    received = testimonial.receiver.received_testimonials.positive
    testimonial.receiver.give_badge("first_transaction", host) if received.count == 1
    Badge.assign_with_levels("active_member", received.count, testimonial.receiver, [3, 10, 25], host)
    if received.collect { |t| "#{t.participation.conversation.listing.listing_type}_#{t.participation.conversation.listing.category}" }.uniq.size == 5
      testimonial.receiver.give_badge("jack_of_all_trades", host)
    end
    badge_levels = { "generous" => 0, "moneymaker" => 0, "helper" => 0, "chauffer" => 0 }
    received.each do |t|
      listing = t.participation.conversation.listing
      badge_levels["generous"] += 1 if listing.category.eql?("item") && listing.offerer?(testimonial.receiver) && listing.lending_or_giving_away?
      badge_levels["moneymaker"] += 1 if listing.category.eql?("item") && listing.offerer?(testimonial.receiver) && listing.selling_or_renting?
      badge_levels["helper"] += 1 if listing.category.eql?("favor") && listing.offerer?(testimonial.receiver)
      badge_levels["chauffer"] += 1 if listing.category.eql?("rideshare") && listing.offerer?(testimonial.receiver)
    end
    badge_levels.each { |badge, level| Badge.assign_with_levels(badge, level, testimonial.receiver, [2, 6, 15], host) }
  end
  
end