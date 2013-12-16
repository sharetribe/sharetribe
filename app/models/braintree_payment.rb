class BraintreePayment < Payment
  attr_accessor :credit_card_number, :credit_card_expiration_date, :cardholder_name, :cvv

  # This is a hacky solution, but currently the receipt for Braintree is not
  # implemented
  def send_receipt_email
    false
  end

  # This is a hacky solution, but currently the receipt for Braintree is not
  # implemented
  def send_payment_email
    false
  end

  def total_sum
    sum_cents.to_f / 100
  end
end