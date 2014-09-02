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
