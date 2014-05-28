class BraintreePaymentGateway < PaymentGateway

  def can_receive_payments_for?(person, listing=nil)
    braintree_account = BraintreeAccount.find_by_person_id(person.id)
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
      new_braintree_settings_payment_path(:person_id => person.id.to_s, :locale => locale)
    else
      show_braintree_settings_payment_path(:person_id => person.id.to_s, :locale => locale)
    end
  end

  def settings_url(person, locale, other_params={})
    if person.braintree_account.blank?
      new_braintree_settings_payment_url(other_params.merge(
        :person_id => person.id.to_s,
        :locale => locale
      ))
    else
      show_braintree_settings_payment_url(other_params.merge(
        :person_id => person.id.to_s,
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
