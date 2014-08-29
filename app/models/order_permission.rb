class OrderPermission < ActiveRecord::Base
  attr_accessible :status, :from_account, :to_account

  belongs_to :from_account, class_name: "PaypalAccount"
  belongs_to :to_account, class_name: "PaypalAccount"

  validates_presence_of :from_account, :to_account

  def status
    read_attribute(:status).to_sym
  end
end
