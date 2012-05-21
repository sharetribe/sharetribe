class CommunityMembership < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :community, :counter_cache => :members_count
  belongs_to :invitation
  
  attr_accessor :email
  
  attr_protected :admin
  
  before_create :set_last_page_load_date_to_current_time
  
  validate :person_can_join_community_only_once, :on => :create
  
  def person_can_join_community_only_once
    if CommunityMembership.find_by_person_id_and_community_id(person_id, community_id)
      errors.add(:base, "You are already a member of this community")
    end
  end
  
  def set_last_page_load_date_to_current_time
    self.last_page_load_date = DateTime.now
  end
  
end
