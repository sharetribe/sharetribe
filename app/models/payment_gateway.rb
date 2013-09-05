class PaymentGateway < ActiveRecord::Base
  
  has_and_belongs_to_many :communities
  
  # methods that must be defined in subclasses, but are not defined here as 
  # this model is never directly used, only via subclasses
  
  # def form_template_dir
  # Which template file directory to use for the payment form
  
  # def payment_data(payment, options={})
  # initializes the payment and returns the data that is needed by the template.
  
  def requires_payout_registration_before_accept?
    false
  end
  
end
