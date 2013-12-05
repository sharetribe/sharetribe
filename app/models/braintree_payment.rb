class BraintreePayment < Payment
  attr_accessor :credit_card_number, :credit_card_expiration_date
end