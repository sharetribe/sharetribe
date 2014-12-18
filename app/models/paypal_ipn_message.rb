# == Schema Information
#
# Table name: paypal_ipn_messages
#
#  id         :integer          not null, primary key
#  body       :text
#  status     :string(64)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaypalIpnMessage < ActiveRecord::Base
  validates_presence_of :body
end
