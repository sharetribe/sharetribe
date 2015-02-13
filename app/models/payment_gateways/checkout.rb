# == Schema Information
#
# Table name: payment_gateways
#
#  id                                   :integer          not null, primary key
#  community_id                         :integer
#  type                                 :string(255)
#  braintree_environment                :string(255)
#  braintree_merchant_id                :string(255)
#  braintree_master_merchant_id         :string(255)
#  braintree_public_key                 :string(255)
#  braintree_private_key                :string(255)
#  braintree_client_side_encryption_key :text
#  checkout_environment                 :string(255)
#  checkout_user_id                     :string(255)
#  checkout_password                    :string(255)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class Checkout < PaymentGateway

  def form_template_dir
    "payments/complex_form"
  end

  def gateway_templates_dir
    "payments/checkout"
  end

  def invoice_form_type
    "complex"
  end

  def payment_data(payment, options={})

    unless options[:mock]
      merchant_id = payment.recipient.checkout_account.merchant_id
      merchant_key = payment.recipient.checkout_account.merchant_key
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
      merchant_key = payment.recipient.checkout_account.merchant_key
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

  def can_receive_payments?(person)
    self.has_registered?(person)
  end

  def register_payout_details(person, checkout_account_params)
    url = "https://rpcapi.checkout.fi/reseller/createMerchant"
    user = checkout_user_id
    password = checkout_password

    if checkout_environment == "production"
      type = 0 # Creates real merchant accounts
    else
      type = 2 # Creates test accounts
    end

    api_params = {
      "company" => person.name,
      "vat_id"  => checkout_account_params.company_id_or_personal_id,
      "name"    => person.name,
      "email"   => person.confirmed_notification_email_to,
      "gsm"     => checkout_account_params.phone_number,
      "type"    => type,
      "info"    => "",
      "address" => checkout_account_params.organization_address,
      "url"     => checkout_account_params.organization_website || person_url(person),
      "kkhinta" => "0",
    }

    if checkout_environment == "production" || checkout_environment == "test"
      response = RestClient::Request.execute(:method => :post, :url => url, :user => user, :password => password, :payload => api_params)
    else
      # Stub response to avoid unnecessary accounts being created (unless config is set to make real accounts)
      #puts "STUBBING A CALL TO MERCHANT API WITH PARAMS: #{api_params.inspect}"
      response = "<merchant><id>375917</id><secret>SAIPPUAKAUPPIAS</secret><banner>http://rpcapi.checkout.fi/banners/5a1e9f504277f6cf17a7026de4375e97.png</banner></merchant>"
    end

    checkout_account = CheckoutAccount.new({
        person_id: person,
        merchant_id: response[/<id>([^<]+)<\/id>/, 1],
        merchant_key: response[/<secret>([^<]+)<\/secret>/, 1],
        company_id_or_personal_id: checkout_account_params.company_id_or_personal_id
      })
    checkout_account.save!
  end

  def has_registered?(person)
    person.checkout_account.present?
  end

  def new_payment
    payment = CheckoutPayment.new
    payment.payment_gateway = self
    payment.community = community
    payment.currency = "EUR"
    payment
  end

  def configured?
    if checkout_environment == "stub"
      true
    else
      [
        checkout_environment,
        checkout_user_id,
        checkout_password
      ].all? { |x| x.present? }
    end
  end

  def gateway_type
    :checkout
  end
end
