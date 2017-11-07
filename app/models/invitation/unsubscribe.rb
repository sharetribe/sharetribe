# == Schema Information
#
# Table name: invitation_unsubscribes
#
#  id           :integer          not null, primary key
#  community_id :integer
#  email        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_invitation_unsubscribes_on_community_id  (community_id)
#  index_invitation_unsubscribes_on_email         (email)
#

class Invitation::Unsubscribe < ApplicationRecord
  belongs_to :community

  validates :community, :email, presence: true

  scope :by_community_and_email, ->(community, email) { where(community: community, email: email) }

  class << self
    def unsubscribe(code)
      invitation = Invitation.find_by(code: code.upcase)
      if invitation
        where(community: invitation.community,
              email: invitation.email.downcase).first_or_create
      end
    end

    def remove_unsubscribed_emails(community, invitation_emails)
      invitation_emails.reject{ |email| by_community_and_email(community, email).any? }
    end
  end
end
