# == Schema Information
#
# Table name: paypal_tokens
#
#  id             :integer          not null, primary key
#  token          :string(64)
#  transaction_id :integer
#  created_at     :datetime
#
# Indexes
#
#  index_paypal_tokens_on_token  (token) UNIQUE
#

class PaypalToken < ActiveRecord::Base
  validates_presence_of :token, :transaction_id
end
