class Badge < ActiveRecord::Base
  
  belongs_to :person
  
  UNIQUE_BADGES = [
    "rookie", "first_transaction"
  ]
  
  validates_presence_of :person_id, :name
  validate :person_does_not_already_have_this_badge
  
  def person_does_not_already_have_this_badge
    existing_badge = Badge.find_by_person_id_and_name(person_id, name)
    errors.add(:base, "Person can't have more than one of each badge.") if existing_badge
  end
  
end
