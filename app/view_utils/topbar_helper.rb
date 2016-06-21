module TopbarHelper

  module_function

  def topbar_props(community:, path_after_locale_change:, user: nil, search_placeholder: nil, locale_param: nil, landing_page: false)

    user_links = Maybe(community.menu_links)
      .map { |menu_links|
        menu_links
          .map { |menu_link|
            {
              link: menu_link.url(I18n.locale),
              title: menu_link.title(I18n.locale),
              priority: menu_link.sort_priority
            }
          }
      }.or_else([])

    links = [
      {
        link: PathHelpers.landing_page_path(
          community_id: community.id,
          logged_in: user.present?,
          default_locale: community.default_locale,
          locale_param: locale_param
        ),
        title: I18n.t("header.home"),
        priority: -1
      },
      {
        link: paths.about_infos_path,
        title: I18n.t("header.about"),
        priority: 0
      },
      {
        link: paths.new_user_feedback_path,
        title: I18n.t("header.contact_us"),
        priority: !user_links.empty? ? user_links.last[:priority] + 1 : 1
      }
    ]

    if user&.has_admin_rights? || community.users_can_invite_new_users
      links << {
        link: paths.new_invitation_path,
        title: I18n.t("header.invite"),
        priority: !user_links.empty? ? user_links.last[:priority] + 2 : 2
      }
    end

    links.concat(user_links)

    location_search_available = true # TODO: fix
    main_search = location_search_available ? MarketplaceService::API::Api.configurations.get(community_id: community.id).data[:main_search] : :keyword

    {
      logo: {
        href: PathHelpers.landing_page_path(
          community_id: community.id,
          default_locale: community.default_locale,
          logged_in: user.present?,
          locale_param: locale_param
        ),
        text: community.name(I18n.locale),
        image: community.wide_logo.present? ? community.stable_image_url(:wide_logo, :header) : nil,
        image_highres: community.wide_logo.present? ? community.stable_image_url(:wide_logo, :header_highres) : nil
      },
      search: {
        mode: main_search.to_s,

        # TODO: figure where to get these
        # keyword_query: params[:q],
        # location_query: params[:lq]
      },
      search_path: '/', # TODO: fix
      menu: {
        links: links,
        limit_priority_links: Maybe(MarketplaceService::API::Api.configurations.get(community_id: community.id).data)[:limit_priority_links].or_else(nil)
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
