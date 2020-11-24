# == Schema Information
#
# Table name: paypal_tokens
#
#  id                   :integer          not null, primary key
#  community_id         :integer          not null
#  token                :string(64)
#  transaction_id       :integer
#  payment_action       :string(32)
#  merchant_id          :string(255)      not null
#  receiver_id          :string(255)      not null
#  created_at           :datetime
#  item_name            :string(255)
#  item_quantity        :integer
#  item_price_cents     :integer
#  currency             :string(8)
#  express_checkout_url :string(255)
#  shipping_total_cents :integer
#
# Indexes
#
#  index_paypal_tokens_on_community_id    (community_id)
#  index_paypal_tokens_on_token           (token) UNIQUE
#  index_paypal_tokens_on_transaction_id  (transaction_id)
#

class PaypalToken < ApplicationRecord
  validates_presence_of :community_id, :token, :transaction_id, :merchant_id, :express_checkout_url
  monetize :item_price_cents, with_model_currency: :currency, allow_nil: true
  monetize :shipping_total_cents, with_model_currency: :currency, allow_nil: true
end
