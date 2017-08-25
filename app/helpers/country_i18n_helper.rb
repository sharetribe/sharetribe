module CountryI18nHelper
  module_function

  def translate_country(country_code)
    country = ISO3166::Country[country_code]
    locale = I18n.locale.to_s.downcase
    [locale, locale.split('-').first].each do |variant|
      name = country.translations[variant]
      return name if name.present?
    end
    return country.local_name
  end

  def translate_list(country_codes)
    FFILocale.setlocale FFILocale::LC_COLLATE, 'en_US.UTF8' # default UCA is good enough
    country_codes.map{|code| [translate_country(code), code]}.sort{ |a,b|  FFILocale.strcoll a[0], b[0] }
  end

end
