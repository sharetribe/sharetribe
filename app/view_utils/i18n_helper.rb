module I18nHelper

  module_function

  def facebook_locale_code(all_locales, current_locale_code)
    locale_code_string = current_locale_code.to_s

    _, _, language, region = all_locales.find { |(_, ident)| ident == locale_code_string }

    if language.present? && region.present?
      "#{language.downcase}_#{region.upcase}"
    else
      nil
    end
  end
end
