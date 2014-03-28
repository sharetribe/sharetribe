class BraintreePayment < Payment
  attr_accessor :credit_card_number, :credit_card_expiration_date, :cardholder_name, :cvv

  def total_sum
    sum_cents.to_f / 100
  end
end
