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
  attr_accessible :email, :api_password, :api_signature, :person, :community

  belongs_to :person
  belongs_to :community

  validates_presence_of :email

  # Validate presence of either person OR community
  validates :person, presence: true, unless: :community
  validates :community, presence: true, unless: :person

  # If community, validate API settings
  with_options if: :community do |admin_account|
    admin_account.validates_presence_of :api_password, :api_signature
  end
end
