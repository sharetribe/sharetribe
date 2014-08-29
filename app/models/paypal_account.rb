class PaypalAccount < ActiveRecord::Base
  attr_accessible :username, :api_password, :api_signature, :person, :community

  belongs_to :person
  belongs_to :community

  validates_presence_of :username, :person, :community
end
