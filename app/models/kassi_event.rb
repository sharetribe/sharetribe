class KassiEvent < ActiveRecord::Base
  
  belongs_to :eventable, :polymorphic => true
  
  has_many :person_comments, :dependent => :destroy
  
  has_many :kassi_event_participations, :dependent => :destroy
  has_many :participants, :through => :kassi_event_participations, :source => :person
  has_and_belongs_to_many :people
  
  def comment_attributes=(attributes)
    person_comments.build(attributes)
  end
  
  def participant_attributes=(attributes)
    attributes.each do |id, role|
      kassi_event_participations.build(:person_id => id, :role => role)
    end
  end
  
  def get_participant_with_role(role)
    participant = nil
    kassi_event_participations.each do |kp|
      participant = kp.person if kp.role.eql?(role)
    end
    return participant
  end
  
  def requester
    get_participant_with_role("requester")
  end
  
  def provider
    get_participant_with_role("provider")
  end
  
  def buyer
    get_participant_with_role("buyer")
  end
  
  def seller
    get_participant_with_role("seller")
  end
  
  # Return true of the given person has already
  # commented on this kassi event
  def has_been_commented_by?(person)
    person_comments.each do |comment|
      return true if comment.author.id == person.id
    end
    return false
  end
  
  # Returns the participant of this event who
  # is not the given person
  def get_other_party(person)
    participants.reject { |p| p.id == person.id }.first
  end
  
  # Return the comment that is not from the given user or nil 
  # if that user has not yet commented this event.
  def get_person_comment_from_other_party(person)
    person_comments.each do |comment|
      return comment unless comment.author.id == person.id
    end
    return nil  
  end
  
  # Returns true if the given person has commented
  # this Kassi event.
  def commented_by?(person)
    person_comments.each { |c| return true if c.author.id == person.id }
    return false
  end
  
end
