module I18nHelper

  module_function

  def facebook_locale_code(all_locales, current_locale_code)
    locale = locale_info(all_locales, current_locale_code)

    if locale && locale[:language].present? && locale[:region].present?
      "#{locale[:language].downcase}_#{locale[:region].upcase}"
    end
  end

  def locale_info(all_locales, current_locale_code)
    locale_code_string = current_locale_code.to_s
    all_locales.find { |l| l[:ident] == locale_code_string }
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

  # Load translation from TranslationService and initialize the CommunityBackend,
  # which then let's you to fetch community specific translations with the good ol'
  # I18n.t() method
  #
  # Params:
  # - community_id
  # - locales: array of locales to load
  #
  # Usage:
  #
  # ```
  # I18nHelper.initialize_community_backend!(123, ["en", "fr"])
  # ```
  def initialize_community_backend!(community_id, locales)
    community_backend = I18n::Backend::CommunityBackend.instance
    community_backend.set_community!(community_id, locales.map(&:to_sym))
    community_translations = TranslationService::API::Api.translations.get(community_id)[:data]
    TranslationServiceHelper.community_translations_for_i18n_backend(community_translations).each { |locale, data|
      # Store community translations to I18n backend.
      #
      # Since the data in data hash is already flatten, we don't want to
      # escape the separators (. dots) in the key
      community_backend.store_translations(locale, data, escape: false)
    }
  end

end
