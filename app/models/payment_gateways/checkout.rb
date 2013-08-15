class Checkout < PaymentGateway

  def form_template
    "payments/complex_form/form"
  end
end