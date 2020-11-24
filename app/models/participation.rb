# == Schema Information
#
# Table name: participations
#
#  id               :integer          not null, primary key
#  person_id        :string(255)
#  conversation_id  :integer
#  is_read          :boolean          default(FALSE)
#  is_starter       :boolean          default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  last_sent_at     :datetime
#  last_received_at :datetime
#  feedback_skipped :boolean          default(FALSE)
#
# Indexes
#
#  index_participations_on_conversation_id  (conversation_id)
#  index_participations_on_person_id        (person_id)
#

class Participation < ApplicationRecord
  belongs_to :conversation, :dependent => :destroy, inverse_of: :participations, touch: true
  belongs_to :person

  scope :by_person, -> (person) { where(person: person) }
  scope :starter, -> { where(is_starter: true) }
  scope :recipient, -> { where(is_starter: false) }
  scope :other_party, -> (person) { where.not(person: person) }
end
