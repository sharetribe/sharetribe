class BraintreePaymentGateway < PaymentGateway

  def settings_path(person, locale)
    if person.braintree_account.blank?
      new_braintree_settings_payment_path(:person_id => person.id.to_s, :locale => locale)
    else
      edit_braintree_settings_payment_path(:person_id => person.id.to_s, :locale => locale)
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
  
end