class Mangopay < PaymentGateway

  def form_template_dir
    "payments/simple_form"
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
  
end