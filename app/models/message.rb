# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

class Message < ActiveRecord::Base

  after_save :update_conversation_read_status

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation

  validates_presence_of :sender_id
  validates_presence_of :content

  def update_conversation_read_status
    conversation.update_attribute(:last_message_at, created_at)
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end
  end
end
