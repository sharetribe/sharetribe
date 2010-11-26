class AssignBadgesToPeople < ActiveRecord::Migration
  def self.up
    People.all.each do |person|
      badge_levels = { "lender" => 0, "volunteer" => 0, "taxi_stand" => 0 }
      person.offers.open.each do |offer|
        badge_levels["lender"] += 1 if offer.category.eql?("item") && offer.share_types.collect(&:name).include?("lend")
        badge_levels["volunteer"] += 1 if offer.category.eql?("favor")
      end
      listing.author.offers.each { |offer| badge_levels["taxi_stand"] += 1 if offer.category.eql?("rideshare") }
      
    end
  end

  def self.down
  end
  
  def give_badge_with_levels
    
  end
end
