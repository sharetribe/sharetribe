class Message < ActiveRecord::Base

  after_save :update_conversation_read_status

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation

  validates_presence_of :sender_id
  validate :content_or_action_present

  # Message must always have either content, action or both
  def content_or_action_present
    errors.add(:base, "Message needs to have either action or content.") if content.blank? && action.blank?
  end

  def update_conversation_read_status
    conversation.update_attribute(:last_message_at, created_at)
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end
  end

  def positive_action?
    ["accept", "confirm", "pay"].include? action
  end

  def negative_action?
    ["reject", "cancel"].include? action
  end

end
