class StripeService::API::MinimumCommissions
  def initialize(min_commissions)
    @min_commissions = monetize_commissions(min_commissions)
  end

  def get(currency)
    currency_code = currency.to_s.upcase
    @min_commissions[currency_code]
  end

  private

  def monetize_commissions(commissions)
    commissions.each_with_object({}) do |(currency, cents), memo|
      memo[currency] = Money.new(cents, currency)
    end
  end
end
