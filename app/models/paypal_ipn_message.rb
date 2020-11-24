# == Schema Information
#
# Table name: paypal_ipn_messages
#
#  id         :integer          not null, primary key
#  body       :text(65535)
#  status     :string(64)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaypalIpnMessage < ApplicationRecord
  validates_presence_of :body

  serialize :body, Hash

  def status
    read_attribute(:status).to_sym unless read_attribute(:status).nil?
  end
end
