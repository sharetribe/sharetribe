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
end