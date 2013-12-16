module PaymentMath

  # SellerCommission assumes the price includes the commission
  module SellerCommission
    class << self
      def seller_gets(price, commission)
        price - PaymentMath.service_fee(price, commission)
      end

      def buyer_pays(price, commission)
        price
      end
    end
  end

  class << self
    def service_fee(price, commission)
      (price * (commission.to_f/100)).to_f.ceil
    end
  end
end