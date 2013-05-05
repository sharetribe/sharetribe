class TestimonialGivenJob < Struct.new(:testimonial_id, :community_id) 
  
  include DelayedAirbrakeNotification
  
  # This before hook should be included in all Jobs to make sure that the service_name is 
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end
  
  def perform
    community = Community.find(community_id)
    testimonial = Testimonial.find(testimonial_id)
    testimonial.participation.update_attribute(:is_read, true)
    testimonial.notify_receiver(community)
    received = testimonial.receiver.received_testimonials.positive
    testimonial.receiver.give_badge("first_transaction", community) if received.count == 1
    Badge.assign_with_levels("active_member", received.count, testimonial.receiver, [3, 10, 25], community)
    if received.collect { |t| "#{t.participation.conversation.listing.listing_type}_#{t.participation.conversation.listing.category.name}" }.uniq.size == 5
      testimonial.receiver.give_badge("jack_of_all_trades", community)
    end
    badge_levels = { "generous" => 0, "moneymaker" => 0, "helper" => 0, "chauffer" => 0 }
    received.each do |t|
      listing = t.participation.conversation.listing
      badge_levels["generous"] += 1 if listing.category.name.eql?("item") && listing.offerer?(testimonial.receiver) && listing.lending_or_giving_away?
      badge_levels["moneymaker"] += 1 if listing.category.name.eql?("item") && listing.offerer?(testimonial.receiver) && listing.selling_or_renting?
      badge_levels["helper"] += 1 if listing.category.name.eql?("favor") && listing.offerer?(testimonial.receiver)
      badge_levels["chauffer"] += 1 if listing.category.name.eql?("rideshare") && listing.offerer?(testimonial.receiver)
    end
    badge_levels.each { |badge, level| Badge.assign_with_levels(badge, level, testimonial.receiver, [2, 6, 15], community) }
  end
  
end