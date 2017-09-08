module CountryI18nHelper
  module_function

  def translate_country(country_code)
    country = ISO3166::Country[country_code]
    return country_code unless country
    locale = I18n.locale.to_s.downcase
    [locale, locale.split('-').first].each do |variant|
      name = country.translations[variant]
      return name if name.present?
    end
    return country.local_name
  end

  def translate_list(country_codes)
    lang = I18n.locale.to_s.downcase.split("-").first
    collator =  if TwitterCldr.supported_locale?(I18n.locale)
                  TwitterCldr::Collation::Collator.new(I18n.locale)
                elsif TwitterCldr.supported_locale?(lang)
                  TwitterCldr::Collation::Collator.new(lang)
                else
                  TwitterCldr::Collation::Collator.new
                end
    list = country_codes.map{|code| [translate_country(code), code]}
    list.map{ |s| [s, collator.get_sort_key(s.first)] }.sort_by(&:last).map(&:first)
  end

  def all_translated_countries
    translate_list(ISO3166::Country.codes)
  end

  def translated_shipping_countries
    translate_list(MarketplaceService::AvailableCurrencies::COUNTRY_SET_STRIPE_AND_PAYPAL)
  end

end
