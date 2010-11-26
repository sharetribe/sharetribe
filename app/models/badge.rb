class Badge < ActiveRecord::Base
  
  belongs_to :person
  
  UNIQUE_BADGES = [
    "rookie", "first_transaction", "jack_of_all_trades",
    "active_member_bronze", "active_member_silver", "active_member_gold",
    "generous_bronze", "generous_silver", "generous_gold",
    "moneymaker_bronze", "moneymaker_silver", "moneymaker_gold",
    "helper_bronze", "helper_silver", "helper_gold",
    "chauffer_bronze", "chauffer_silver", "chauffer_gold",
    "listing_freak_bronze", "listing_freak_silver", "listing_freak_gold",
    "lender_bronze", "lender_silver", "lender_gold",
    "volunteer_bronze", "volunteer_silver", "volunteer_gold",
    "taxi_stand_bronze", "taxi_stand_silver", "taxi_stand_gold",
    "enthusiast_bronze", "enthusiast_silver", "enthusiast_gold",
    "commentator_bronze", "commentator_silver", "commentator_gold",
    "santa"
  ]
  
  LEVELS = ["bronze", "silver", "gold"]
  
  validates_presence_of :person_id
  validates_inclusion_of :name, :in => UNIQUE_BADGES
  validate :person_does_not_already_have_this_badge
  
  def person_does_not_already_have_this_badge
    existing_badge = Badge.find_by_person_id_and_name(person_id, name)
    errors.add(:base, "You already have this badge.") if existing_badge
  end
  
  def self.assign_with_levels(badge_name, condition_value, receiver, levels, host)
    levels.each_with_index do |level, index|
      if condition_value == level
        receiver.give_badge("#{badge_name}_#{LEVELS[index]}", host)
      end  
    end  
  end
  
end
