# == Schema Information
#
# Table name: paypal_accounts
#
#  id           :integer          not null, primary key
#  person_id    :string(255)
#  community_id :integer
#  email        :string(255)
#  payer_id     :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  active       :boolean          default(FALSE)
#
# Indexes
#
#  index_paypal_accounts_on_community_id  (community_id)
#  index_paypal_accounts_on_payer_id      (payer_id)
#  index_paypal_accounts_on_person_id     (person_id)
#

class PaypalAccount < ApplicationRecord
  belongs_to :person
  belongs_to :community
  has_one :order_permission, dependent: :destroy
  has_one :billing_agreement, dependent: :destroy

  scope :has_permission_and_agreement, -> {
    joins(:order_permission, :billing_agreement)
  }
  scope :active, -> { where(active: true) }
  scope :active_users, -> {
    active.has_permission_and_agreement.where.not(person_id: nil)
  }
  scope :by_community, ->(community) { where(community: community) }

  def connected?
    active? && order_permission.present? && billing_agreement.present?
  end
end
