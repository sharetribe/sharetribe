# == Schema Information
#
# Table name: payment_gateways
#
#  id                                   :integer          not null, primary key
#  community_id                         :integer
#  type                                 :string(255)
#  braintree_environment                :string(255)
#  braintree_merchant_id                :string(255)
#  braintree_master_merchant_id         :string(255)
#  braintree_public_key                 :string(255)
#  braintree_private_key                :string(255)
#  braintree_client_side_encryption_key :text
#  checkout_environment                 :string(255)
#  checkout_user_id                     :string(255)
#  checkout_password                    :string(255)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class PaymentGateway < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :community
  has_many :payments

  # methods that must be defined in subclasses, but are not defined here as
  # this model is never directly used, only via subclasses

  # def form_template_dir
  # Which template file directory to use for the payment form

  # def payment_data(payment, options={})
  # initializes the payment and returns the data that is needed by the template.

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

  # If the payment gateway has terms of use that need to be shown to the user override this and return true
  # And add those terms in the corresponding file. (See Braintree for example)
  def has_additional_terms_of_use
    false
  end

  # by default return the class name, but this can be overridden
  # in child classes if name is not exaxtly the class name
  def name
    self.class.name.downcase
  end

  def new_payment_path(person, message, locale)
    new_person_message_payment_path(person, message, :locale => locale)
  end

  def new_payment_url(person, message, locale, other_params={})
    new_person_message_payment_url(person, message, other_params.merge(:locale => locale))
  end

  def hold_in_escrow
    false
  end
end
