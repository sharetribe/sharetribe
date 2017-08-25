module CountryI18nHelper
  module_function

  def translate(country_code)
    country = ISO3166::Country[country_code]
    locale = I18n.locale.to_s.downcase
    [locale, locale.split('-').first].each do |variant|
      name = country.translations[variant]
      return name if name.present?
    end
    return country.name
  end

  def translate_list(country_codes)
    country_codes.map{|code| [translate(code), code]}
  end

end
