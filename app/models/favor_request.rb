class FavorRequest < Conversation
  
  has_one :kassi_event, :as => :eventable
  
  belongs_to :favor
  
  VALID_STATUS = ["pending", "accepted", "rejected"]
  
  validates_inclusion_of :status, :in => VALID_STATUS
  
  # Returns the owner of the reserved items
  def favor_offerer
    favor.owner
  end
  
  # Returns the person who has made the reservation.
  def favor_requester
    participants.reject { |p| p.id == favor_offerer.id }.first
  end
  
end