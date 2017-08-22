module MoneyViewUtils
  extend ActionView::Helpers::NumberHelper
  extend MoneyRails::ActionViewExtension # TODO: Remove when feature flag is removed

  module_function

  # Converts instance of Money to properly formatted and localized string for view purposes
  # Replaces spaces with narrow non breaking spaces, we do not want monetary amounts to be split on separate lines
  def to_humanized(m, locale = I18n.locale)
    return "" if m.nil?

    # Explicitly resolve formatting. WebTranslateit resolves
    # translations to nils which causes an error with number_to_currency
    formatting = currency_opts(locale, m.currency)
    precision = formatting[:digits]
    zero_cents = "0" * precision

    number_to_currency(m.amount,
                       unit: formatting[:symbol],
                       delimiter: formatting[:delimiter],
                       separator: formatting[:separator],
                       format: formatting[:format],
                       precision: precision)
      .tr(" ", "\u202F")
      .gsub("#{formatting[:separator]}#{zero_cents}", "") # remove cents if they are zero
      .encode('utf-8')
  end

  # Return a hash of currency formatting options, sets defaults if
  # translations are not present
  # Currency needs to be an instance of Money::Currency
  def currency_opts(locale, currency)
    {
      separator: I18n.t("number.currency.format.separator", locale: locale) || ".",
      delimiter: I18n.t("number.currency.format.delimiter", locale: locale) || ",",
      format: I18n.t("number.currency.format.format", locale: locale) || "%u%n",
      digits: currency.exponent.to_i,
      symbol: currency.symbol
    }
  end
end
