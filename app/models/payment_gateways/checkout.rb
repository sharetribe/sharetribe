class Checkout < PaymentGateway

  def form_template_dir
    "payments/complex_form"
  end
  
  def payment_data(payment, options={})
    
    unless options[:mock]
      merchant_id = payment.recipient_organization.merchant_id
      merchant_key = payment.recipient_organization.merchant_key
    else
      # Make it possible to demonstrate payment system with mock payments if that's set on in community settings
      merchant_id = "375917"
      merchant_key = "SAIPPUAKAUPPIAS"
    end
    
    payment_data = {
      "VERSION"   => "0001",
      "STAMP"     => "sharetribe_#{payment.id}",
      "AMOUNT"    => payment.total_sum.cents,
      "REFERENCE" => "1009",
      "MESSAGE"   => payment.summary_string,
      "LANGUAGE"  => "FI",
      "MERCHANT"  => merchant_id,
      "RETURN"    => options[:return_url],
      "CANCEL"    => options[:cancel_url],
      "COUNTRY"   => "FIN",
      "CURRENCY"  => "EUR",
      "DEVICE"    => 1,
      "CONTENT"   => 1,
      "TYPE"      => 0,
      "ALGORITHM" => 2,
      "DELIVERY_DATE" => 2.weeks.from_now.strftime("%Y%m%d")
    }
    payment_data["STAMP"] = Devise.friendly_token if Rails.env.test?
    payment_data["MAC"] = Digest::MD5.hexdigest("#{payment_data['VERSION']}+#{payment_data['STAMP']}+#{payment_data['AMOUNT']}+#{payment_data['REFERENCE']}+#{payment_data['MESSAGE']}+#{payment_data['LANGUAGE']}+#{payment_data['MERCHANT']}+#{payment_data['RETURN']}+#{payment_data['CANCEL']}+#{payment_data['REJECT']}+#{payment_data['DELAYED']}+#{payment_data['COUNTRY']}+#{payment_data['CURRENCY']}+#{payment_data['DEVICE']}+#{payment_data['CONTENT']}+#{payment_data['TYPE']}+#{payment_data['ALGORITHM']}+#{payment_data['DELIVERY_DATE']}+#{payment_data['FIRSTNAME']}+#{payment_data['FAMILYNAME']}+#{payment_data['ADDRESS']}+#{payment_data['POSTCODE']}+#{payment_data['POSTOFFICE']}+#{merchant_key}").upcase
    
    return payment_data
    
  end
  
  def check_payment(payment, options={})
    
    results = {}
    
    unless options[:mock]
      merchant_key = payment.recipient_organization.merchant_key
    else
      # Make it possible to demonstrate payment system with mock payments if that's set on in community settings
      merchant_key = "SAIPPUAKAUPPIAS"
    end
    
    params = options[:params]
    
    calculated_mac = Digest::MD5.hexdigest("#{merchant_key}&#{params["VERSION"]}&#{params["STAMP"]}&#{params["REFERENCE"]}&#{params["PAYMENT"]}&#{params["STATUS"]}&#{params["ALGORITHM"]}").upcase
    
    if calculated_mac == params["MAC"]  
      if ["2","5","6","7","8","9","10"].include?(params["STATUS"])
        results[:status] = "paid"
        results[:notice] = I18n.t("layouts.notifications.payment_successful")
      elsif ["3","4"].include?(params["STATUS"])
        results[:status] = "delayed"
        results[:notice] = I18n.t("layouts.notifications.payment_waiting_for_later_accomplishment")
      else
        results[:status] = "canceled"
        results[:warning] = I18n.t("layouts.notifications.payment_canceled")
      end  
    else # the security check didn't go through
      results[:status] = "error"
      results[:error] = I18n.t("layouts.notifications.error_in_payment")
      ApplicationHelper.send_error_notification("Payment security check failed (CheckoutFI)", "Payment Error", params)   
    end
    
    return results
  end
end