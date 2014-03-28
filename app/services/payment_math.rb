# Helpers module for Payment mathematics
# All calculations are done in cents!
module PaymentMath

  # SellerCommission assumes the price includes the commission
  module SellerCommission
    class << self
      def seller_gets(price_cents, commission)
        price_cents - PaymentMath.service_fee(price_cents, commission)
      end
    end
  end

  class << self
    def service_fee(price_cents, commission)
      ceil_cents(price_cents * (commission.to_f/100))
    end

    def ceil_cents(price_cents)
      (price_cents.to_f / 100).ceil * 100
    end
  end
end
