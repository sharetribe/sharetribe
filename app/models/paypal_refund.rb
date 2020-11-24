# == Schema Information
#
# Table name: paypal_refunds
#
#  id                  :integer          not null, primary key
#  paypal_payment_id   :integer
#  currency            :string(8)
#  payment_total_cents :integer
#  fee_total_cents     :integer
#  refunding_id        :string(64)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_paypal_refunds_on_refunding_id  (refunding_id) UNIQUE
#

class PaypalRefund < ApplicationRecord
  validates_presence_of :paypal_payment_id
  validates_uniqueness_of :refunding_id
end
