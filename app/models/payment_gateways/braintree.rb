class Braintree < PaymentGateway
  include Rails.application.routes.url_helpers

  def settings_path(person, locale)
    braintree_settings_payment_path(:person_id => person.id.to_s, :locale => locale)
  end
end