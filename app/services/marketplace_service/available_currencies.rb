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

  CURRENCIES = SortedSet.new(["USD"].concat(COUNTRY_CURRENCIES.values))

  # Austria, Belgium, Denmark, Finland, France, Germany, Ireland, Luxembourg, Netherlands, Norway, Spain, Sweden, Switzerland, the United Kingdom, the United States
  COUNTRY_SET_STRIPE_AND_PAYPAL = ['AT', 'BE', 'DK', 'FI', 'FR', 'DE', 'IE', 'LU', 'NL', 'NO', 'ES', 'SE', 'CH', 'GB', 'US']

  # Australia, Brazil, Canada, Czech Republic, Hong Kong, Hungary, Israel,  Japan, Malaysia, Mexico, New Zealand,  Poland, Philippines, Russia, Singapore, Taiwan, Thailand
  COUNTRY_SET_PAYPAL_ONLY = ['AU', 'BR', 'CA', 'CZ', 'HK', 'HU', 'IL', 'JP', 'MY', 'MX', 'NZ', 'PL', 'PH', 'RU', 'SG', 'TW', 'TH']

  VALID_CURRENCIES = {
    "USD" => :country_sets,
    "AUD" => :country_sets,
    "BRL" => "BR",
    "GBP" => :country_sets,
    "CAD" => :country_sets,
    "CZK" => "CZ",
    "DKK" => :country_sets,
    "EUR" => :country_sets,
    "HKD" => :country_sets,
    "HUF" => "HU",
    "ILS" => :country_sets,
    "JPY" => :country_sets,
    "MYR" => :country_sets,
    "MXN" => "MX",
    "TWD" => :country_sets,
    "NZD" => :country_sets,
    "NOK" => :country_sets,
    "PHP" => :country_sets,
    "PLN" => :country_sets,
    "RUB" => :country_sets,
    "SGD" => :country_sets,
    "SEK" => :country_sets,
    "CHF" => :country_sets,
    "THB" => :country_sets,
  }

  module_function

  def stripe_allows_country_and_currency?(country, currency)
    rule = VALID_CURRENCIES[currency]
    if rule == :country_sets
      COUNTRY_SET_STRIPE_AND_PAYPAL.include?(country)
    else
      country == rule
    end
  end

  def paypal_allows_country_and_currency?(country, currency)
    rule = VALID_CURRENCIES[currency]
    if rule == :country_sets
      COUNTRY_SET_STRIPE_AND_PAYPAL.include?(country) || COUNTRY_SET_PAYPAL.include?(country)
    else
      country == rule
    end
  end

end
