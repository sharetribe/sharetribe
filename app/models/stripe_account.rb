# == Schema Information
#
# Table name: stripe_accounts
#
#  id                       :integer          not null, primary key
#  person_id                :string(255)      not null
#  community_id             :integer
#  stripe_seller_id         :string(255)
#  first_name               :string(255)
#  last_name                :string(255)
#  address_country          :string(255)
#  address_city             :string(255)
#  address_line1            :string(255)
#  address_postal_code      :string(255)
#  address_state            :string(255)
#  birth_date               :date
#  tos_date                 :datetime
#  tos_ip                   :string(255)
#  stripe_bank_id           :string(255)
#  bank_account_number      :string(255)
#  bank_country             :string(255)
#  bank_currency            :string(255)
#  bank_account_holder_name :string(255)
#  bank_account_holder_type :string(255)
#  bank_routing_number      :string(255)
#  stripe_customer_id       :string(255)
#  stripe_source_info       :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_stripe_accounts_on_community_id  (community_id)
#  index_stripe_accounts_on_person_id     (person_id)
#

class StripeAccount < ApplicationRecord

  belongs_to :customer
  belongs_to :community

end
