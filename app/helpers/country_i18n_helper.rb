module CountryI18nHelper
  module_function

  def translate(country_code)
    country = ISO3166::Country[country_code]
    locale = I18n.locale.to_s.downcase
    [locale, locale.split('-').first].each do |variant|
      name = country.translations[variant]
      return name if name.present?
    end
    return country.local_name
  end

  def translate_list(country_codes)
    collator = TwitterCldr::Collation::Collator.new(I18n.locale)
    list = country_codes.map{|code| [translate(code), code]}
    list.map{ |s| [s, collator.get_sort_key(s.first)] }.sort_by(&:last).map(&:first)
  end

end
