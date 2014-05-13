# Helpers module for Payment mathematics
# All calculations are done in cents!
module PaymentMath

  class << self
    def ceil_cents(price_cents)
      (price_cents.to_f / 100).ceil * 100
    end
  end
end
