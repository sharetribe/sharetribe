class BraintreePayment < Payment
  attr_accessor :credit_card_number, :credit_card_expiration_date, :cardholder_name, :cvv
  attr_accessible :braintree_transaction_id

  monetize :sum_cents, :allow_nil => true

  def sum_exists?
    !!sum_cents
  end

  def total_commission
    Money.new(PaymentMath.ceil_cents(super.cents), "USD")
  end

  def total_sum
    sum
  end
end
