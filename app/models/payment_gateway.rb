class PaymentGateway < ActiveRecord::Base
  
  has_and_belongs_to_many :communities
  
  # methods that must be defined in subclasses, but are not defined here as 
  # this model is never directly used, only via subclasses
  
  # form_template
  # Which template file to use for the payment form
  
  
end
