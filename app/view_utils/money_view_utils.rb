module MoneyViewUtils
  extend ActionView::Helpers::NumberHelper
  extend MoneyRails::ActionViewExtension # TODO: Remove when feature flag is removed

  module_function

  # Converts instance of Money to properly formatted and localized string for view purposes
  # Replaces spaces with narrow non breaking spaces, we do not want monetary amounts to be split on separate lines
  def to_humanized(m, locale = I18n.locale)
    # TODO: Remove feature flag
    if FeatureFlagHelper.feature_enabled?(:currency_formatting)
      return "" if m.nil?
      separator = I18n.t("number.currency.format.separator", locale: locale)
      precision = m.currency.exponent.to_i
      zero_cents = "0" * precision
      number_to_currency(m.amount, unit: m.symbol, locale: locale, precision: m.currency.exponent.to_i)
        .tr(" ", "\u202F")
        .gsub("#{separator}#{zero_cents}", "") # remove cents if they are zero
        .encode('utf-8')
    else
      humanized_money_with_symbol(m).upcase
    end
  rescue FeatureFlagHelperNotInitialized
    humanized_money_with_symbol(m).upcase
  end
end
