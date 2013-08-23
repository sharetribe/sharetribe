class Mangopay < PaymentGateway

  def form_template_dir
    "payments/simple_form"
  end
  
  def gateway_templates_dir
    "payments/mangopay"
  end
  
  def payment_data(payment, options={})
  
    contribution = MangoPay::Contribution.create({
              "UserID" => payment.recipient.mangopay_id, 
              "WalletID" => 0, #use always the personal wallet 
              "Amount" => payment.total_sum.cents, 
              "ReturnURL" => options[:return_url],
              "PaymentMethodType" => "cb_visa_mastercard", 
              "Culture" => payment_compatible_locale(options[:locale])
    })
    
    return {:payment_url => contribution["PaymentURL"]}
  end
  
  def check_payment(payment, options={})
    contribution = MangoPay::Contribution.details(options[:params]["ContributionID"])
    
    results = {}
    
    if contribution["IsSucceeded"] && contribution["Error"].nil?
      results[:status] = "paid"
      results[:notice] = I18n.t("layouts.notifications.payment_successful")
    elsif contribution["IsCompleted"] && contribution["AnswerMessage"].match(/Payment cancelled/)
        results[:status] = "canceled"
        results[:warning] = I18n.t("layouts.notifications.payment_canceled")  
    else # Something else happened
      results[:status] = "error"
      results[:error] = I18n.t("layouts.notifications.error_in_payment")
      ApplicationHelper.send_error_notification("Payment error: not completed or canceled (MangoPay)", "Payment Error", options[:params])   
    end
    
    return results
  end    
  
  def can_receive_payments_for?(person)
    return true if person.mangopay_id
    
    #if no MangoPay id yet, try to create if enough data available
    return register_to_mangopay(person)
  
  end
  
  private
  
  def register_to_mangopay(person)
    u = MangoPay::User.create({
        'Tag' => person.id,
        'Email' => person.email,
        'FistName' => person.given_name,
        'LastName' => person.family_name,
        'CanRegisterMeanOfPayment' => true
    })
    if u["ErrorCode"]
      return false
    else
      person.update_attribute(:mangopay_id, u["ID"]) 
      return true
    end
  end
  
  # will return the parameter locale if Mangopay supports it
  def payment_compatible_locale(locale)
    locale = locale.to_s.split("-").first
    if ["fr", "en", "es", "it", "pt", "de", "nl", "fi"].include?(locale)
      return locale
    else
      return "en"
    end
  end
  
end