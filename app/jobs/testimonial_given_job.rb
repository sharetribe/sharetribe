class TestimonialGivenJob < Struct.new(:testimonial_id, :host) 
  
  def perform
    testimonial = Testimonial.find(testimonial_id)
    testimonial.notify_receiver(host)
    testimonial.receiver.give_badge("first_transaction", host) if testimonial.receiver.received_testimonials.positive.count == 1
    Badge.assign_with_levels("active_member", testimonial.receiver.received_testimonials.positive.count, testimonial.receiver, [3, 10, 20], host)
    if testimonial.receiver.received_testimonials.positive.collect { |t| "#{t.participation.conversation.listing.listing_type}_#{t.participation.conversation.listing.category}" }.uniq.size == 5
      testimonial.receiver.give_badge("jack_of_all_trades", host) unless testimonial.receiver.has_badge?("jack_of_all_trades")
    end
  end
  
end