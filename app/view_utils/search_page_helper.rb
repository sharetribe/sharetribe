module SearchPageHelper

  module_function

  def searchpage_props(page:, per_page:, bootstrapped_data:, notifications_to_react:, display_branding_info:,
                  community:, path_after_locale_change:, user: nil, search_placeholder: nil,
                  locale_param: nil, current_path: nil, landing_page: false, host_with_port:)

    {
      i18n: {
        locale: I18n.locale,
        defaultLocale: I18n.default_locale,
        localeInfo: I18nHelper.locale_info(Sharetribe::AVAILABLE_LOCALES, I18n.locale)
      },
      marketplace: {
        marketplace_color1: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1],
        location: current_path, # request.fullpath,
        notifications: notifications_to_react,
        displayBrandingInfo: display_branding_info,
        linkToSharetribe: "https://www.sharetribe.com/?utm_source=#{community.ident}.sharetribe.com&utm_medium=referral&utm_campaign=nowl-footer"
      },
      searchPage: {
        page: page,
        per_page: per_page,
        data: bootstrapped_data
      },
      topbar: TopbarHelper.topbar_props({
        community: community,
        path_after_locale_change: path_after_locale_change,
        user: user,
        search_placeholder: search_placeholder,
        locale_param: locale_param,
        current_path: current_path,
        landing_page: landing_page,
        host_with_port: host_with_port,
        }),
    }
  end
end
