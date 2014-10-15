# == Schema Information
#
# Table name: paypal_tokens
#
#  id             :integer          not null, primary key
#  community_id   :integer          not null
#  token          :string(64)
#  transaction_id :integer
#  merchant_id    :string(255)      not null
#  created_at     :datetime
#
# Indexes
#
#  index_paypal_tokens_on_token  (token) UNIQUE
#

class PaypalToken < ActiveRecord::Base
  validates_presence_of :community_id, :token, :transaction_id, :merchant_id
  attr_accessible :community_id, :token, :transaction_id, :merchant_id
end
