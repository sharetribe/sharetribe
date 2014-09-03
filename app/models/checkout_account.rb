class CheckoutAccount < ActiveRecord::Base
  attr_accessible :merchant_id, :merchant_key, :company_id
  belongs_to :person
  #TODO Move to form object and remove after refactoring !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  attr_accessor :organization_address, :phone_number, :organization_website
end
