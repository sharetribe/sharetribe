class PaypalService::MinimumCommissions
  include PaypalService::MinimumCommissionInjector # injects `minimum_commissions_cents`

  def get(currency)
    currency_code = currency.to_s.upcase

    Maybe(minimum_commissions_cents)[currency_code].map { |cents|
      Money.new(cents, currency_code)
    }.or_else(nil)
  end

end
