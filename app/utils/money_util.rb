module MoneyUtil
  module_function

  # Give string that represents money and get back the amount in cents
  #
  # Notice! The parsing strategy should follow the frontend validation strategy
  def parse_str_to_cents(money_str)
    # Current front-end validation: /^\d+((\.|\,)\d{0,2})?$/
    normalized = money_str.sub(",", ".")
    cents = normalized.to_f * 100
    cents.to_i
  end

  def parse_str_to_money(money_str, currency)
    Money.new(parse_str_to_cents(money_str), currency)
  end

  def to_money(cents, currency)
    Money.new(cents, currency) unless cents.nil?
  end

  def to_dot_separated_str(m)
    units, subs = m.cents.abs.divmod(m.currency.subunit_to_unit).map(&:to_s)
    [units, subs.rjust(2, "0")].join(".")
  end

end
