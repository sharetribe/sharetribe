class AssignBadgesToPeople < ActiveRecord::Migration
  
  def self.up
    badge_receivers = []
    Person.all.each do |person|
      
      # Badges related to adding listings
      assign_badge("rookie", person, badge_receivers) if person.listings.size > 0
      assign_badge_with_levels("listing_freak", person.listings.open.count, person, [5, 20, 40], badge_receivers)
      badge_levels = { "lender" => 0, "volunteer" => 0, "taxi_stand" => 0 }
      person.offers.open.each do |offer|
        badge_levels["lender"] += 1 if offer.category.eql?("item") && offer.share_types.collect(&:name).include?("lend")
        badge_levels["volunteer"] += 1 if offer.category.eql?("favor")
      end
      person.offers.each { |offer| badge_levels["taxi_stand"] += 1 if offer.category.eql?("rideshare") }
      badge_levels.each { |badge, level| assign_badge_with_levels(badge, level, person, [3, 10, 25], badge_receivers) }
      
      # Badges related to received testimonials
      received = person.received_testimonials.positive
      assign_badge("first_transaction", person, badge_receivers) if received.count > 0
      assign_badge_with_levels("active_member", received.count, person, [3, 10, 25], badge_receivers)
      if received.collect { |t| "#{t.participation.conversation.listing.listing_type}_#{t.participation.conversation.listing.category}" }.uniq.size > 5
        assign_badge("jack_of_all_trades", person, badge_receivers)
      end
      badge_levels2 = { "generous" => 0, "moneymaker" => 0, "helper" => 0, "chauffer" => 0 }
      received.each do |t|
        listing = t.participation.conversation.listing
        badge_levels2["generous"] += 1 if listing.category.eql?("item") && listing.offerer?(person) && listing.lending_or_giving_away?
        badge_levels2["moneymaker"] += 1 if listing.category.eql?("item") && listing.offerer?(person) && listing.selling_or_renting?
        badge_levels2["helper"] += 1 if listing.category.eql?("favor") && listing.offerer?(person)
        badge_levels2["chauffer"] += 1 if listing.category.eql?("rideshare") && listing.offerer?(person)
      end
      badge_levels2.each { |badge, level| assign_badge_with_levels(badge, level, person, [2, 6, 15], badge_receivers) }
      
      # Other badges
      assign_badge_with_levels("commentator", person.authored_comments.count, person, [3, 10, 30], badge_receivers)
    end
    badge_receivers.uniq.each { |br| Delayed::Job.enqueue(BadgesMigratedJob.new(br.id)) }
  end

  def self.down
  end
  
  def self.assign_badge(badge_name, receiver, badge_receivers)
    unless receiver.has_badge?(badge_name)
      badge = Badge.create(:person_id => receiver.id, :name => badge_name)
      badge_receivers << receiver
    end
  end
  
  def self.assign_badge_with_levels(badge_name, condition_value, receiver, levels, badge_receivers)
    levels.each_with_index do |level, index|
      if condition_value >= level
        assign_badge("#{badge_name}_#{Badge::LEVELS[index]}", receiver, badge_receivers)
      end
    end
  end
  
end
