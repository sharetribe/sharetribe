class Checkout < PaymentGateway

  def form_template_dir
    "payments/complex_form"
  end
  
  def gateway_templates_dir
    "payments/checkout"
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
    
    data = {
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
    data["STAMP"] = Devise.friendly_token if Rails.env.test?
    data["MAC"] = Digest::MD5.hexdigest("#{data['VERSION']}+#{data['STAMP']}+#{data['AMOUNT']}+#{data['REFERENCE']}+#{data['MESSAGE']}+#{data['LANGUAGE']}+#{data['MERCHANT']}+#{data['RETURN']}+#{data['CANCEL']}+#{data['REJECT']}+#{data['DELAYED']}+#{data['COUNTRY']}+#{data['CURRENCY']}+#{data['DEVICE']}+#{data['CONTENT']}+#{data['TYPE']}+#{data['ALGORITHM']}+#{data['DELIVERY_DATE']}+#{data['FIRSTNAME']}+#{data['FAMILYNAME']}+#{data['ADDRESS']}+#{data['POSTCODE']}+#{data['POSTOFFICE']}+#{merchant_key}").upcase
    
    return{:payment_url => "https://payment.checkout.fi/", :hidden_fields => data}
    
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
  
  def can_receive_payments_for?(person, listing)
    listing.organization.merchant_id && listing.organization.merchant_key
  end
end