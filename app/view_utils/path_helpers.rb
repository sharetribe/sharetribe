module PathHelpers

  module_function

  def search_path(community_id:, logged_in:, locale_param:, default_locale:, opts: {})
    if opts.is_a?(ActionController::Parameters)
      opts = opts.to_unsafe_hash
    end

    o = opts.dup.symbolize_keys
    o.delete("controller")
    o.delete("action")
    o.delete("locale")

    non_default_locale = ->(locale) { locale.present? && locale != default_locale.to_s}
    not_present = ->(x) { !x.present? }

    case [CustomLandingPage::LandingPageStore.enabled?(community_id),
          logged_in,
          locale_param]
    when matches([true, false, non_default_locale])
      paths.search_with_locale_path(o.merge(locale: locale_param))
    when matches([true, __, __])
      paths.search_without_locale_path(o.merge(locale: nil))
    when matches([false, false, non_default_locale])
      paths.homepage_with_locale_path(o.merge(locale: locale_param))
    when matches([false, __, __])
      paths.homepage_without_locale_path(o.merge(locale: nil))
    end
  end

  def search_url(community_id:, opts: {})
    case [CustomLandingPage::LandingPageStore.enabled?(community_id),
          opts[:locale].present?]
    when matches([true, true])
      paths.search_with_locale_url(opts)
    when matches([true, false])
      paths.search_without_locale_url(opts.merge(locale: nil))
    when matches([false, true])
      paths.homepage_with_locale_url(opts)
    when matches([false, false])
      paths.homepage_without_locale_url(opts.merge(locale: nil))
    end
  end

  def landing_page_path(community_id:, logged_in:, locale_param:, default_locale:)
    non_default_locale = ->(locale) { locale && locale != default_locale.to_s}

    case [CustomLandingPage::LandingPageStore.enabled?(community_id), logged_in, locale_param]
    when matches([true, false, non_default_locale])
      paths.landing_page_with_locale_path(locale: locale_param)
    when matches([true, __, __])
      paths.landing_page_without_locale_path(locale: nil)
    when matches([false, false, non_default_locale])
      paths.homepage_with_locale_path(locale: locale_param)
    else
      paths.homepage_without_locale_path(locale: nil)
    end
  end

  def paths
    @_url_helpers ||= Rails.application.routes.url_helpers
  end

  # Path for locale change
  #
  # - If logged in: URL points to I18nController with redirect_url query string
  # - If not logged in: Change the locale in the URL. No redirect_url query string
  #
  # For non-logged users, we don't want to include redirect_url query string, because
  # it will create a number of unique links that the crawlers will request even though
  # the page is the same
  def change_locale_path(is_logged_in:, locale:, redirect_uri:)
    if is_logged_in
      paths.change_locale_path(locale: locale, redirect_uri: redirect_uri)
    else
      path_after_locale_change(locale: locale, redirect_uri: redirect_uri)
    end
  end

  # Path after the current_user locale has been changed OR
  # the new locale path, if anonymous user.
  def path_after_locale_change(locale:, redirect_uri:)
    "/#{locale}/#{redirect_uri}"
  end
end
