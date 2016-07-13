module TopbarHelper

  module_function

  def topbar_props(community:, path_after_locale_change:, user: nil, search_placeholder: nil, locale_param: nil, landing_page: false)

    links = [
      {
        link: PathHelpers.landing_page_path(
          community_id: community.id,
          logged_in: user.present?,
          default_locale: community.default_locale,
          locale_param: locale_param
        ),
        title: I18n.t("header.home")
      },
      {
        link: paths.about_infos_path,
        title: I18n.t("header.about")
      },
      {
        link: paths.new_user_feedback_path,
        title: I18n.t("header.contact_us"),
      }
    ]

    if user&.has_admin_rights? || community.users_can_invite_new_users
      links << {
        link: paths.new_invitation_path,
        title: I18n.t("header.invite"),
      }
    end

    links.concat(Maybe(community.menu_links)
      .map { |menu_links|
        menu_links.map { |menu_link|
          {
            link: menu_link.url(I18n.locale),
            title: menu_link.title(I18n.locale)
          }
        }
      }.or_else([]))

    {
      logo: {
        href: PathHelpers.landing_page_path(
          community_id: community.id,
          default_locale: community.default_locale,
          logged_in: user.present?,
          locale_param: locale_param
        ),
        text: community.name(I18n.locale),
        image: community.wide_logo.present? ? community.wide_logo.url(:header) : nil,
        image_highres: community.wide_logo.present? ? community.wide_logo.url(:header_highres) : nil
      },
      search: {
        mode: 'keyword-and-location',
        keyword_placeholder: search_placeholder || I18n.t("web.topbar.search_placeholder"),
        location_placeholder: 'Location'
      },
      menu: {
        links: links,
      },
      locales: landing_page ? nil : locale_props(community, I18n.locale, path_after_locale_change),
      avatarDropdown: {
        customColor: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1],
        avatar: {
          image: user&.image.present? ? user.image.url(:thumb) : missing_profile_image_path(),
        }
      },
      newListingButton: {
        text: I18n.t("homepage.index.post_new_listing"),
        customColor: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1]
      },
      i18n: {
        locale: I18n.locale,
        defaultLocale: I18n.default_locale
      },
      isAdmin: user&.has_admin_rights? || false,
      unReadMessagesCount: MarketplaceService::Inbox::Query.notification_count(user&.id, community.id)
    }
  end


  def locale_props(community, current_locale, path_after_locale_change)
    community_locales = community.locales.map { |loc_ident|
      Sharetribe::AVAILABLE_LOCALES.find { |app_loc| app_loc[:ident] == loc_ident }
    }.compact.map { |loc|
      {
        locale_name: loc[:name],
        locale_ident: loc[:ident],
        change_locale_uri: paths.change_locale_path({locale: loc[:ident], redirect_uri: path_after_locale_change})
      }
    }

    { current_locale_ident: I18n.locale,
      current_locale: Maybe(Sharetribe::AVAILABLE_LOCALES.find { |l| l[:ident] == current_locale.to_s })[:language].or_else(current_locale).to_s,
      available_locales: community_locales }
  end

  def missing_profile_image_path
    ActionController::Base.helpers.image_path("profile_image/thumb/missing.png")
  end

  def paths
    @_url_herlpers ||= Rails.application.routes.url_helpers
  end
end
