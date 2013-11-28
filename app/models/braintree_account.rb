class BraintreeAccount < ActiveRecord::Base
  belongs_to :person
  
  attr_accessor :first_name, :last_name, :email, :phone, :address_street_address, :address_postal_code, :address_locality, :address_region, :date_of_birth, :ssn, :routing_number, :account_number
  
end
