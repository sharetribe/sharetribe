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
#  gateway_commission_percentage        :integer
#  gateway_commission_fixed_cents       :integer
#  gateway_commission_fixed_currency    :string(255)
#

class BraintreePaymentGateway < PaymentGateway

  def can_receive_payments?(person)
    braintree_account = person.braintree_account
    braintree_account.present? && braintree_account.status == "active"
  end

  def new_payment_path(person, message, locale)
    edit_person_message_braintree_payment_path(:id => message.payment.id, :person_id => person.id.to_s, :message_id => message.id.to_s, :locale => locale)
  end

  def new_payment_url(person, message, locale, other_params={})
    edit_person_message_braintree_payment_url(other_params.merge(
      :id => message.payment.id,
      :person_id => person.id.to_s,
      :message_id => message.id.to_s,
      :locale => locale
    ))
  end

  def settings_path(person, locale)
    if person.braintree_account.blank?
      new_braintree_settings_payment_path(person, :locale => locale)
    else
      show_braintree_settings_payment_path(person, :locale => locale)
    end
  end

  def settings_url(person, locale, other_params={})
    if person.braintree_account.blank?
      new_braintree_settings_payment_url(person, other_params.merge(
        :locale => locale
      ))
    else
      show_braintree_settings_payment_url(person, other_params.merge(
        :locale => locale
      ))
    end
  end

  def has_additional_terms_of_use
    true
  end

  def name
    "braintree"
  end

  def form_template_dir
    "payments/simple_form"
  end

  def invoice_form_type
    "simple"
  end

  def new_payment
    payment = BraintreePayment.new
    payment.payment_gateway = self
    payment.community = community
    payment.currency = "USD"
    payment
  end

  def no_fixed_commission
    Money.new(0, "USD")
  end

  def hold_in_escrow
    true
  end

  def configured?
    [
      braintree_environment,
      braintree_merchant_id,
      braintree_master_merchant_id,
      braintree_public_key,
      braintree_private_key,
      braintree_client_side_encryption_key
    ].all? { |x| x.present? }
  end
end
