module MarketplaceService::AvailableCurrencies

  # This list maps country codes to the best guess default currency to use
  # In a marketplace based on that country. For the others, it's USD
  COUNTRY_CURRENCIES = {
      "AU" => "AUD",
      "KI" => "AUD",
      "TV" => "AUD",
      "NF" => "AUD",
      "BR" => "BRL",
      "CA" => "CAD",
      "CZ" => "CZK",
      "DK" => "DKK",
      "FO" => "DKK",
      "HK" => "HKD",
      "HU" => "HUF",
      "IL" => "ILS",
      "JP" => "JPY",
      "MY" => "MYR",
      "MX" => "MXN",
      "NO" => "NOK",
      "CK" => "NZD",
      "NZ" => "NZD",
      "PH" => "PHP",
      "PL" => "PLN",
      "GB" => "GBP",
      "GG" => "GBP",
      "JE" => "GBP",
      "RU" => "RUB",
      "SG" => "SGD",
      "SE" => "SEK",
      "CH" => "CHF",
      "LI" => "CHF",
      "TW" => "TWD",
      "TH" => "THB",
      "AL" => "EUR",
      "AD" => "EUR",
      "AT" => "EUR",
      "BE" => "EUR",
      "BG" => "EUR",
      "HR" => "EUR",
      "CY" => "EUR",
      "FI" => "EUR",
      "FR" => "EUR",
      "GF" => "EUR",
      "DE" => "EUR",
      "GR" => "EUR",
      "GP" => "EUR",
      "NL" => "EUR",
      "IE" => "EUR",
      "IT" => "EUR",
      "LT" => "EUR",
      "LU" => "EUR",
      "MK" => "EUR",
      "MT" => "EUR",
      "MQ" => "EUR",
      "YT" => "EUR",
      "MC" => "EUR",
      "ME" => "EUR",
      "PT" => "EUR",
      "RE" => "EUR",
      "SM" => "EUR",
      "RS" => "EUR",
      "SK" => "EUR",
      "SI" => "EUR",
      "ES" => "EUR",
      "VA" => "EUR"
  }

  CURRENCIES = [
    "AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BIF", "BMD",
    "BND", "BOB", "BRL", "BSD", "BWP", "BZD", "CAD", "CDF", "CHF", "CLP", "CNY", "COP", "CRC", "CVE", "CZK", "DJF",
    "DKK", "DOP", "DZD", "EGP", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GIP", "GMD", "GNF", "GTQ", "GYD", "HKD",
    "HNL", "HRK", "HTG", "HUF", "IDR", "ILS", "INR", "ISK", "JMD", "JPY", "KES", "KGS", "KHR", "KMF", "KRW", "KYD",
    "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRO", "MUR", "MVR",
    "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN",
    "PYG", "QAR", "RON", "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SEK", "SGD", "SHP", "SLL", "SOS", "SRD", "STD",
    "SVC", "SZL", "THB", "TJS", "TOP", "TRY", "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VND", "VUV",
    "WST", "XAF", "XCD", "XOF", "XPF", "YER", "ZAR", "ZMW",
  ]

  CURRENCIES_WITH_NAMES = CURRENCIES.map do |currency|
    info = Money::Currency.table[currency.downcase.to_sym]
    [[info[:iso_code], info[:symbol], info[:name]].join(", "), currency]
  end

  # Austria, Belgium, Denmark, Finland, France, Germany, Ireland, Luxembourg, Netherlands, Norway, Spain, Sweden, Switzerland, the United Kingdom, the United States
  COUNTRY_SET_STRIPE_AND_PAYPAL = ['AT', 'BE', 'DK', 'FI', 'FR', 'DE', 'IE', 'LU', 'NL', 'NO', 'ES', 'SE', 'CH', 'GB', 'US']

  # Australia, Brazil, Canada, Czech Republic, Hong Kong, Hungary, Israel, Italy,  Japan, Malaysia, Mexico, New Zealand,  Poland, Portugal, Philippines, Russia, Singapore, Taiwan, Thailand
  COUNTRY_SET_PAYPAL_ONLY = ['AU', 'BR', 'CA', 'CZ', 'HK', 'HU', 'IL', 'IT', 'JP', 'MY', 'MX', 'NZ', 'PL', 'PT', 'PH', 'RU', 'SG', 'TW', 'TH']

  VALID_CURRENCIES = {
    "AUD" => :country_sets,
    "BRL" => "BR",
    "CAD" => :country_sets,
    "CHF" => :country_sets,
    "CZK" => "CZ",
    "DKK" => :country_sets,
    "EUR" => :country_sets,
    "GBP" => :country_sets,
    "HKD" => :country_sets,
    "HUF" => "HU",
    "ILS" => :country_sets,
    "JPY" => :country_sets,
    "MXN" => "MX",
    "MYR" => :country_sets,
    "NOK" => :country_sets,
    "NZD" => :country_sets,
    "PHP" => :country_sets,
    "PLN" => :country_sets,
    "RUB" => :country_sets,
    "SEK" => :country_sets,
    "SGD" => :country_sets,
    "THB" => :country_sets,
    "TWD" => :country_sets,
    "USD" => :country_sets,
  }

  module_function

  def stripe_allows_country_and_currency?(country, currency, stripe_mode)
    rule = VALID_CURRENCIES[currency]
    if rule == :country_sets
      if COUNTRY_SET_STRIPE_AND_PAYPAL.include?(country)
        if [:direct, :separate].include?(stripe_mode)
          StripeService::Store::StripeAccount::VALID_BANK_CURRENCIES.include?(currency)
        else
          true
        end
      end
    else
      country == rule
    end
  end

  def paypal_allows_country_and_currency?(country, currency)
    rule = VALID_CURRENCIES[currency]
    if rule == :country_sets
      COUNTRY_SET_STRIPE_AND_PAYPAL.include?(country) || COUNTRY_SET_PAYPAL_ONLY.include?(country)
    else
      country == rule
    end
  end

end
