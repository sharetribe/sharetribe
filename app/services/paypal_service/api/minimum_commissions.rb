class PaypalService::API::MinimumCommissions
  def initialize(min_commissions)
    @min_commissions = monetize_commissions(min_commissions)
  end

  def get(currency)
    currency_code = currency.to_s.upcase
    @min_commissions[currency_code]
  end

  private

  def monetize_commissions(commissions)
    commissions.reduce({}) do |memo, (currency, cents)|
      memo[currency] = Money.new(cents, currency)
      memo
    end
  end
end
