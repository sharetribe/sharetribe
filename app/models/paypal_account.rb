class PaypalAccount < ActiveRecord::Base
  belongs_to :person
  belongs_to :community

  validates_presence_of :person
  validates_presence_of :username
  validates_precence_of :api_key
  validates_precence_of :signature
end
