class CommunityMembership < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :community
  belongs_to :invitation
  
  before_create :set_last_page_load_date_to_current_time
  
  def set_last_page_load_date_to_current_time
    self.last_page_load_date = DateTime.now
  end
  
end
