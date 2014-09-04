# == Schema Information
#
# Table name: billing_agreements
#
#  id                   :integer          not null, primary key
#  from_account_id      :integer          not null
#  to_account_id        :integer          not null
#  status               :string(255)      default("pending"), not null
#  billing_agreement_id :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class BillingAgreement < ActiveRecord::Base
  attr_accessible :status, :billing_agreement_id, :from_account, :to_account

  belongs_to :from_account, class_name: "PaypalAccount"
  belongs_to :to_account, class_name: "PaypalAccount"

  validates_presence_of :from_account, :to_account

  def status
    read_attribute(:status).to_sym
  end
end
