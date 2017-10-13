# == Schema Information
#
# Table name: marketplace_sender_emails
#
#  id                        :integer          not null, primary key
#  community_id              :integer          not null
#  name                      :string(255)
#  email                     :string(255)      not null
#  verification_status       :string(32)       not null
#  verification_requested_at :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_marketplace_sender_emails_on_community_id  (community_id)
#

class MarketplaceSenderEmail < ApplicationRecord
  # TODO Implementation

  belongs_to :community

  scope :verified, -> { where(verification_status: :verified) }
end
