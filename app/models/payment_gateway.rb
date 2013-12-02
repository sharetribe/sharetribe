class PaymentGateway < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  has_many :community_payment_gateways, :dependent => :destroy 
  has_many :communities, :through => :community_payment_gateways
  
  # Allow only one object per gateway class to be stored in DB
  validates_uniqueness_of :type
  
  # methods that must be defined in subclasses, but are not defined here as 
  # this model is never directly used, only via subclasses
  
  # def form_template_dir
  # Which template file directory to use for the payment form
  
  # def payment_data(payment, options={})
  # initializes the payment and returns the data that is needed by the template.
  
  def requires_payout_registration_before_accept?
    false
  end
  
  # this is called after the payment is paid.
  # some gateways might have actions related to this hook, e.g. instant payout
  def handle_paid_payment(payment)
    # nothing to do by default
  end
  
  
  # this is called after the payout information is entered.
  # some gateways might have actions related to this hook, e.g. cretating a payout/beneficiary object or checking the validity
  def register_payout_details(person)
    # nothing to do by default
  end

  def has_registered?(person)
    # nothing by default
  end

  def settings_path(person, locale)
    payments_person_settings_path(:person_id => person.id.to_s, :locale => locale)
  end
end
