class Mangopay < PaymentGateway

  def form_template_dir
    "payments/simple_form"
  end
  
end