module TopbarHelper

  module_function

  def topbar_props(community:, path_after_locale_change:, user: nil, search_placeholder: nil,
                   locale_param: nil, current_path: nil, landing_page: false, host_with_port:)

    links = links(community: community, user: user, locale_param: locale_param, host_with_port: host_with_port)

    main_search =
      if FeatureFlagHelper.location_search_available
        community.configuration.main_search
      else
        :keyword
      end

    search_path_string = PathHelpers.search_url({
      community_id: community.id,
      opts: {
        only_path: true,
      }
    })

    given_name, family_name = *PersonViewUtils.person_display_names(user, community)
    avatar_image = user&.image&.present? && !user.image_processing ? { url: user.image.url(:thumb) } : nil

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
      search: landing_page ? nil : {
        search_placeholder: search_placeholder,
        mode: main_search.to_s,
      },
      search_path: search_path_string,
      menu: {
        links: links,
        limit_priority_links: community.configuration.limit_priority_links
      },
      locales: landing_page ? nil : locale_props(community, I18n.locale, path_after_locale_change, user.present?),
      avatarDropdown: {
        avatar: {
          image: avatar_image,
          givenName: given_name,
          familyName: family_name,
        },
      },
      newListingButton: {
        text: I18n.t("homepage.index.post_new_listing"),
      },
      i18n: {
        locale: I18n.locale,
        defaultLocale: I18n.default_locale
      },
      marketplace: {
        marketplace_color1: CommonStylesHelper.marketplace_colors(community)[:marketplace_color1],
        location: current_path
      },
      user: {
        loggedInUsername: user&.username,
        isAdmin: user&.has_admin_rights?(community) || false,
      },
      unReadMessagesCount: InboxService.notification_count(user&.id, community.id)
    }
  end

  def links(community:, user:, locale_param:, host_with_port:)
    user_links = Maybe(community.menu_links)
      .map { |menu_links|
        menu_links
          .map { |menu_link|
            {
              link: menu_link.url(I18n.locale),
              title: menu_link.title(I18n.locale),
              priority: menu_link.sort_priority,
              external: link_external?(menu_link.url(I18n.locale), host_with_port)
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
        link: paths.about_infos_path(locale: locale_param),
        title: I18n.t("header.about"),
        priority: 0
      },
      {
        link: paths.new_user_feedback_path(locale: locale_param),
        title: I18n.t("header.contact_us"),
        priority: !user_links.empty? ? user_links.last[:priority] + 1 : 1
      }
    ]

    if user&.has_admin_rights?(community) || community.users_can_invite_new_users
      links << {
        link: paths.new_invitation_path(locale: locale_param),
        title: I18n.t("header.invite"),
        priority: !user_links.empty? ? user_links.last[:priority] + 2 : 2
      }
    end

    links + user_links
  end

  def locale_props(community, current_locale, path_after_locale_change, is_logged_in)
    community_locales = community.locales.map { |loc_ident|
      Sharetribe::AVAILABLE_LOCALES.find { |app_loc| app_loc[:ident] == loc_ident }
    }.compact.map { |loc|
      {
        locale_name: loc[:name],
        locale_ident: loc[:ident],
        change_locale_uri: PathHelpers.change_locale_path(is_logged_in: is_logged_in,
                                                          locale: loc[:ident],
                                                          redirect_uri: path_after_locale_change)
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

  def link_external?(url, host_with_port)
    /^(https?:\/\/)?#{host_with_port}((\/|\?).*)?$/.match(url).nil?
  end
end
