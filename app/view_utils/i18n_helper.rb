module I18nHelper

  module_function

  def facebook_locale_code(all_locales, current_locale_code)
    locale_code_string = current_locale_code.to_s

    locale = all_locales.find { |l| l[:ident] == locale_code_string }

    if locale && locale[:language].present? && locale[:region].present?
      "#{locale[:language].downcase}_#{locale[:region].upcase}"
    end
  end

  def select_locale(user_locale:, param_locale:, community_locales:, community_default:, all_locales:)

    # Use user locale, if community supports it
    locale_from_user = Maybe(user_locale).select { |locale| community_locales.include?(locale) }.or_else(nil)
    return locale_from_user if locale_from_user.present?

    # Use fallback of user locale, if community supports it
    locale_from_user_fallback = Maybe(user_locale)
                                .flat_map { |locale| Maybe(all_locales.find { |l| l[:ident] == locale }).map { |l| l[:fallback] } }
                                .select { |locale| community_locales.include?(locale) }
                                .or_else(nil)
    return locale_from_user_fallback if locale_from_user_fallback.present?

    # Use locale from URL param, if community supports it
    locale_from_param = Maybe(param_locale).select { |locale| community_locales.include?(locale) }.or_else(nil)
    return locale_from_param if locale_from_param.present?

    # Use fallback of param locale, if community supports it
    locale_from_param_fallback = Maybe(param_locale)
                                 .flat_map { |locale| Maybe(all_locales.find { |l| l[:ident] == locale }).map { |l| l[:fallback] } }
                                 .select { |locale| community_locales.include?(locale) }
                                 .or_else(nil)
    return locale_from_param_fallback if locale_from_param_fallback.present?

    # Use community default locale
    return community_default

  end
end
