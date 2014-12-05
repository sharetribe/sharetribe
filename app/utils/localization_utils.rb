module LocalizationUtils
  module_function

  # Country code (ISO 3166-1 alpha-2) i.e. sv_SE -> SE is the country code
  def country_code(country)
    unless country.blank?
      CountrySelect.countries.select{|key, hash|
        return key if hash.downcase == country.downcase
      }
    end
    return nil
  end

end