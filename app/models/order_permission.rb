# == Schema Information
#
# Table name: order_permissions
#
#  id              :integer          not null, primary key
#  from_account_id :integer          not null
#  to_account_id   :integer          not null
#  status          :string(255)      default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OrderPermission < ActiveRecord::Base
  attr_accessible :status, :from_account, :to_account

  belongs_to :from_account, class_name: "PaypalAccount"
  belongs_to :to_account, class_name: "PaypalAccount"

  validates_presence_of :from_account, :to_account

  def status
    read_attribute(:status).to_sym
  end
end
