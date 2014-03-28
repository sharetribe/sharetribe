module Util
  module Hash
    class << self
      def compact(h)
        h.delete_if { |k, v| v.nil? }
      end
    end
  end

  module MoneyUtil
    module_function

    # Give string that represents money and get back the amount in cents
    #
    # Notice! The parsing strategy should follow the frontend validation strategy
    def parse_money_to_cents(money_str)
      # Current front-end validation: /^\d+((\.|\,)\d{0,2})?$/
      normalized = money_str.sub(",", ".");
      cents = normalized.to_f * 100
      cents.to_i
    end
  end
end
