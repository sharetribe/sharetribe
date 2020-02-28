# == Schema Information
#
# Table name: stripe_accounts
#
#  id                 :bigint           not null, primary key
#  person_id          :string(255)
#  community_id       :integer
#  stripe_seller_id   :string(255)
#  stripe_bank_id     :string(255)
#  stripe_customer_id :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  api_version        :string(255)
#
# Indexes
#
#  index_stripe_accounts_on_api_version   (api_version)
#  index_stripe_accounts_on_community_id  (community_id)
#  index_stripe_accounts_on_person_id     (person_id)
#

class StripeAccount < ApplicationRecord

  belongs_to :person
  belongs_to :community

  scope :active_users, -> { where.not(person_id: nil) }
  scope :by_community, ->(community) { where(community: community) }

  def connected?
    stripe_seller_id.present?
  end
end
