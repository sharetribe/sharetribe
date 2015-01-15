module MoneyUtil
  module_function

  # Give string that represents money and get back the amount in currency subunits
  #
  # Notice! The parsing strategy should follow the frontend validation strategy
  def parse_str_to_subunits(money_str, currency)
    # Current front-end validation: /^\d+((\.|\,)\d{0,2})?$/
    (money_str.sub(",", ".").to_f * Money::Currency.new(currency).subunit_to_unit)
      .to_i
  end

  def parse_str_to_money(money_str, currency)
    Money.new(parse_str_to_subunits(money_str, currency), currency)
  end

  def to_money(cents, currency)
    Money.new(cents, currency) unless cents.nil?
  end

  def to_dot_separated_str(m)
    units, subs = m.cents.abs.divmod(m.currency.subunit_to_unit).map(&:to_s)
    [units, subs.rjust(2, "0")].join(".")
  end

  # Get only full units. No rounding.
  def to_units(m)
    m.cents / m.currency.subunit_to_unit
  end

end
