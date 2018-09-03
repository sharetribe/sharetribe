module TransactionService::AvailableCurrencies

  # This list maps country codes to the best guess default currency to use
  # In a marketplace based on that country. For the others, it's USD
  COUNTRY_CURRENCIES = {
      "AR" => "ARS",
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
      "IN" => "INR",
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
      "VA" => "EUR",
      "US" => "USD"
  }
  OLD_CURRENCY_SET = SortedSet.new(["USD"].concat(COUNTRY_CURRENCIES.values))

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

  # Austria, Belgium, Denmark, Finland, France, Germany, Ireland, Luxembourg, Netherlands, Norway, Spain, Sweden, Switzerland, the United Kingdom, the United States
  # Australia, Canada, Hong Kong, New Zealand
  # Portugal, Italy
  # Puerto Rico
  COUNTRY_SET_STRIPE_AND_PAYPAL = ['AT', 'BE', 'DK', 'FI', 'FR', 'DE', 'IE', 'LU', 'NL', 'NO', 'ES', 'SE', 'CH', 'GB', 'US',
                                   'AU', 'CA', 'HK', 'NZ',
                                   'PT', 'IT',
                                   'PR']

  # Countries listed by Paypal
  # Brazil, Czech Republic, Hungary, Israel, Italy, Japan, Mexico, Malaysia, Poland, Philippines, Portugal, Russia, Singapore, Taiwan, Thailand
  # COUNTRY_SET_PAYPAL_ONLY = ['BR', 'CZ', 'HU', 'IL', 'IT', 'JP', 'MX', 'MY', 'PL', 'PH', 'PT', 'RU', 'SG', 'TW', 'TH']
  # All countries around the world
  COUNTRY_SET_PAYPAL_ONLY = ISO3166::Country.all.map{|c| c.alpha2}

  VALID_CURRENCIES = {
    "ARS" => :country_sets,
    "AUD" => :country_sets,
    "BRL" => "BR", # BRL is valid only for PayPal accounts in Brazil
    "CAD" => :country_sets,
    "CHF" => :country_sets,
    "CZK" => :country_sets,
    "DKK" => :country_sets,
    "EUR" => :country_sets,
    "GBP" => :country_sets,
    "HKD" => :country_sets,
    "HUF" => :country_sets,
    "INR" => "IN", # INR is valid only for PayPal accounts in India
    "ILS" => :country_sets,
    "JPY" => :country_sets,
    "MXN" => :country_sets,
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
    VALID_CURRENCIES[currency] && COUNTRY_SET_STRIPE_AND_PAYPAL.include?(country) &&
      (stripe_mode == :destination || StripeService::Store::StripeAccount::VALID_BANK_CURRENCIES.include?(currency))
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
