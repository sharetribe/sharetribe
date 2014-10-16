# == Schema Information
#
# Table name: paypal_payments
#
#  id                         :integer          not null, primary key
#  community_id               :integer          not null
#  transaction_id             :integer          not null
#  payer_id                   :string(64)       not null
#  receiver_id                :string(64)       not null
#  order_id                   :string(64)       not null
#  order_date                 :datetime         not null
#  currency                   :string(8)        not null
#  order_total_cents          :integer          not null
#  authorization_id           :string(64)
#  authorization_date         :datetime
#  authorization_expires_date :datetime
#  authorization_total_cents  :integer
#  payment_id                 :string(64)
#  payment_date               :datetime
#  payment_total_cents        :integer
#  fee_total_cents            :integer
#  payment_status             :string(64)       not null
#  pending_reason             :string(64)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_paypal_payments_on_authorization_id  (authorization_id) UNIQUE
#  index_paypal_payments_on_order_id          (order_id) UNIQUE
#  index_paypal_payments_on_transaction_id    (transaction_id) UNIQUE
#

class PaypalPayment < ActiveRecord::Base
  attr_accessible(
    :community_id,
    :transaction_id,
    :payer_id,
    :receiver_id,
    :order_id,
    :order_date,
    :currency,
    :order_total_cents,
    :authorization_id,
    :authorization_date,
    :authorization_expires_date,
    :authorization_total_cents,
    :payment_id,
    :payment_date,
    :payment_total_cents,
    :fee_total_cents,
    :payment_status,
    :pending_reason)

  belongs_to :transaction

  validates_presence_of(
    :community_id,
    :transaction_id,
    :payer_id,
    :receiver_id,
    :order_id,
    :order_date,
    :currency,
    :order_total_cents,
    :payment_status)
end
