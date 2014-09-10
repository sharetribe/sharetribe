# == Schema Information
#
# Table name: paypal_accounts
#
#  id            :integer          not null, primary key
#  person_id     :string(255)
#  community_id  :integer
#  email         :string(255)      not null
#  api_password  :string(255)
#  api_signature :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PaypalAccount < ActiveRecord::Base
  attr_accessible :email, :api_password, :api_signature, :person_id, :community_id

  belongs_to :person
  belongs_to :community
  has_one :order_permission, :dependent => :destroy
end
