class BraintreeAccount < ActiveRecord::Base
  belongs_to :person

  validates_presence_of :person
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_format_of :email, :with => /^[A-Z0-9._%\-\+\~\/]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
  validates_presence_of :address_street_address
  validates_presence_of :address_postal_code
  validates_presence_of :address_locality
  validates_presence_of :address_region
  validates_presence_of :date_of_birth
  validates_presence_of :routing_number
  validates_presence_of :account_number
end
