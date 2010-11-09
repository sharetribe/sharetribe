class Badge < ActiveRecord::Base
  
  belongs_to :person
  
  UNIQUE_BADGES = [
    "rookie", "first_transaction", "active_member_bronze", "active_member_silver", "active_member_gold"
  ]
  
  validates_presence_of :person_id, :name
  validate :person_does_not_already_have_this_badge
  
  def person_does_not_already_have_this_badge
    existing_badge = Badge.find_by_person_id_and_name(person_id, name)
    errors.add(:base, "You already have this badge.") if existing_badge
  end
  
end
