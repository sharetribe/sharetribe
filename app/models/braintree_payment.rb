class BraintreePayment < Payment
  attr_accessor :credit_card_number, :credit_card_expiration_date, :cardholder_name, :cvv
  attr_accessible :braintree_transaction_id

  monetize :sum_cents, :allow_nil => true

  # Payment excluding VAT and commission
  def sum_without_vat_and_commission
    sum
  end

  def sum_exists?
    !!sum_cents
  end

  def total_sum
    sum_cents.to_f / 100
  end

  def gateway_commission_percentage
    0
  end

  def gateway_commission_fixed
    0
  end
end
