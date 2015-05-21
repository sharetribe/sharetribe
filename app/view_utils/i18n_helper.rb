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

  def select_locale(user_locale:, param_locale:, community_locales:, community_default:, all_locales:)

    # Use user locale, if community supports it
    user = Maybe(user_locale).select { |locale| community_locales.include?(locale) }.or_else(nil)
    return user if user.present?

    # Use fallback of user locale, if community supports it
    user_fallback = Maybe(user_locale)
                    .flat_map { |locale| Maybe(all_locales.find { |(_, ident)| ident == locale }).map { |(_, _, _, _, fallback)| fallback } }
                    .or_else(nil)
    return user_fallback if user_fallback.present?

    # Use locale from URL param, if community supports it
    param = Maybe(param_locale).select { |locale| community_locales.include?(locale) }.or_else(nil)
    return param if param.present?

    # Use fallback of param locale, if community supports it
    param_fallback = Maybe(param_locale)
                    .flat_map { |locale| Maybe(all_locales.find { |(_, ident)| ident == locale }).map { |(_, _, _, _, fallback)| fallback } }
                    .or_else(nil)
    return param_fallback if param_fallback.present?

    # Use community default locale
    return community_default

  end
end
