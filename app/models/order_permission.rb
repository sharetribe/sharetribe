# == Schema Information
#
# Table name: order_permissions
#
#  id                 :integer          not null, primary key
#  paypal_account_id  :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  request_token      :string(255)      not null
#  paypal_username_to :string(255)      not null
#  scope              :string(255)
#  verification_code  :string(255)
#

class OrderPermission < ActiveRecord::Base
  attr_accessible :paypal_account, :request_token, :paypal_username_to, :scope, :verification_code

  belongs_to :paypal_account, class_name: "PaypalAccount"

  validates_presence_of :paypal_account, :request_token, :paypal_username_to
end
