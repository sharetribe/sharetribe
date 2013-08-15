class Mangopay < PaymentGateway

  def form_template
    "payments/simple_form/form"
  end
  
end