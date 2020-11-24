class LandingPageController < ActionController::Metal

  # Shorthand for accessing CustomLandingPage service namespace
  CLP = CustomLandingPage

  # Needed for rendering
  #
  # See Rendering Helpers: http://api.rubyonrails.org/classes/ActionController/Metal.html
  #
  include AbstractController::Rendering
  include ActionController::ConditionalGet
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"

  # Ensure ActiveSupport::Notifications events are fired
  include ActionController::Instrumentation

  # Adds helper_method
  include ActionController::Helpers

  # Add redirect_to
  include ActionController::Redirecting

  # Include route helpers.
  #
  # This needs to be included last! Otherwise you may get error saying
  # that you need to include url_helpers in order to use #url_for
  #
  include Rails.application.routes.url_helpers

  helper CLP::MarkdownHelper
  helper CLP::BackgroundHelper

  include HSTS

  CACHE_TIME = APP_CONFIG[:clp_cache_time].to_i.seconds
  CACHE_HEADER = "X-CLP-Cache"

  FONT_PATH = APP_CONFIG[:font_proximanovasoft_url]

  def index
    return if perform_redirect!

    com = community(request)
    cid = com.id
    is_private = com.private?
    user_logged_in = user(request).present?
    cta = is_private && !user_logged_in ? "signup" : "search" # cta: Call to action
    default_locale = community(request).default_locale
    version = CLP::LandingPageStore.released_version(cid)
    locale_param = params[:locale]
    script_digest = Digest::MD5.hexdigest(custom_head_scripts.to_s)

    begin
      content = nil
      cache_meta = CLP::Caching.fetch_cache_meta(cid, version, locale_param, cta, script_digest)
      cache_hit = true

      hsts_header, hsts_header_value = HSTS.hsts_header(request)

      if hsts_header
        headers[hsts_header] = hsts_header_value
      end

      if cache_meta.nil?
        cache_hit = false
        content = build_html(
          community_id: cid,
          default_locale: default_locale,
          locale_param: locale_param,
          version: version,
          cta: cta
        )
        cache_meta = CLP::Caching.cache_content!(
          cid, version, locale_param, content, CACHE_TIME, cta, script_digest)
      end

      if stale?(etag: cache_meta[:digest],
                last_modified: cache_meta[:last_modified],
                template: false,
                public: true)

        content = CLP::Caching.fetch_cached_content(cid, version, cache_meta[:digest])
        if content.nil?
          # This should not happen since html is cached longer than metadata
          cache_hit = false
          content = build_html(
            community_id: cid,
            default_locale: default_locale,
            locale_param: locale_param,
            version: version,
            cta: cta
          )
        end

        self.status = 200
        self.response_body = content
      end
      # There's an implicit else here because stale? has the
      # side-effect of setting response to HEAD 304 if we have a match
      # for conditional get.

      headers[CACHE_HEADER] = cache_hit ? "1" : "0"

      if is_private
        # Don't add browser cache to private marketplaces
        # In private marketplaces, we need to render different
        # HTML is the user is logged in
        expires_now
      else
        expires_in(CACHE_TIME, public: true)
      end
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end

  def preview
    return if perform_redirect!

    com = community(request)
    cid = com.id
    is_private = com.private?
    user_logged_in = user(request).present?
    cta = is_private && !user_logged_in ? "signup" : "search" # cta: Call to action

    default_locale = community(request).default_locale

    preview_version = parse_int(params[:preview_version])
    locale_param = params[:locale]

    begin
      structure = CLP::LandingPageStore.load_structure(cid, preview_version)

      # Tell robots to not index and to not follow any links
      headers["X-Robots-Tag"] = "none"

      self.status = 200
      self.response_body = render_landing_page(
        default_locale: default_locale,
        locale_param: locale_param,
        structure: structure,
        cta: cta
      )
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end

  include ActionView::Helpers::JavaScriptHelper


  private

  def perform_redirect!
    redirect_params = {
      community: community(request),
      plan: plan(request),
      request: request
    }

    MarketplaceRouter.perform_redirect(redirect_params) do |target|
      if target[:message]
        redirect_to community_not_available_path
      else
        url = target[:url] || send(target[:route_name], protocol: target[:protocol])
        redirect_to(url, status: target[:status])
      end
    end
  end

  # Override basic instrumentation and provide additional info for
  # lograge to consume. These are pulled and logged in environment
  # configs.
  def append_info_to_payload(payload)
    super
    payload[:community_id] = community(request)&.id
    payload[:current_user_id] = user(request)&.id

    ControllerLogging.append_request_info_to_payload!(request, payload)
  end

  def initialize_i18n!(cid, locale)
    I18nHelper.initialize_community_backend!(cid, [locale])
  end

  def build_html(community_id:, default_locale:, locale_param:, version:, cta:)
    structure = CLP::LandingPageStore.load_structure(community_id, version)
    render_landing_page(
      default_locale: default_locale,
      structure: structure,
      locale_param: locale_param,
      cta: cta
    )
  end

  def build_paths(search_path, locale_param)
    { "search" => search_path.call(),
      "all_categories" => search_path.call(category: "all"),
      "signup" => sign_up_path(locale: locale_param),
      "login" => login_path(locale: locale_param),
      "about" => about_infos_path(locale: locale_param),
      "contact_us" => new_user_feedback_path(locale: locale_param),
      "post_a_new_listing" => new_listing_path(locale: locale_param),
      "how_to_use" => how_to_use_infos_path(locale: locale_param),
      "terms" => terms_infos_path(locale: locale_param),
      "new_invitation" => new_invitation_path(locale: locale_param),
      "privacy" => privacy_infos_path(locale: locale_param)
    }
  end

  def build_denormalizer(cid:, default_locale:, locale_param:, landing_page_locale:, sitename:, cta:)
    search_path = ->(opts = {}) {
      PathHelpers.search_path(
        community_id: cid,
        logged_in: false,
        locale_param: locale_param,
        default_locale: default_locale,
        opts: opts
      )
    }

    # Application paths
    paths = build_paths(search_path, locale_param)

    marketplace_data = CLP::MarketplaceDataStore.marketplace_data(cid, landing_page_locale)
    name_display_type = marketplace_data["name_display_type"]

    category_data = CLP::CategoryStore.categories(cid, landing_page_locale, search_path)

    CLP::Denormalizer.new(
      link_resolvers: {
        "path" => CLP::LinkResolver::PathResolver.new(paths),
        "marketplace_data" => CLP::LinkResolver::MarketplaceDataResolver.new(marketplace_data, cta),
        "assets" => CLP::LinkResolver::AssetResolver.new(APP_CONFIG[:clp_asset_url], sitename),
        "translation" => CLP::LinkResolver::TranslationResolver.new(landing_page_locale),
        "category" => CLP::LinkResolver::CategoryResolver.new(category_data),
        "listing" => CLP::LinkResolver::ListingResolver.new(cid, landing_page_locale, locale_param, name_display_type)
      }
    )
  end

  def parse_int(int_str_or_nil)
    Integer(int_str_or_nil || "")
  rescue ArgumentError
    nil
  end

  def community(request)
    @current_community ||= request.env[:current_marketplace] # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def user(request)
    @user ||= request.env["warden"]&.user
  end

  def plan(request)
    @current_plan ||= request.env[:current_plan] # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def community_customization(request, locale)
    community(request).community_customizations.where(locale: locale).first
  end

  def community_context(request, locale)
    c = community(request)

    { id: c.id,
      favicon: c.favicon.url,
      apple_touch_icon: c.stable_image_url(:logo, :apple_touch),
      facebook_locale: facebook_locale(locale),
      facebook_connect_id: c.facebook_connect_id,
      google_maps_key: MarketplaceHelper.google_maps_key(c.id),
      end_user_analytics: c.end_user_analytics,
      google_analytics_key: c.google_analytics_key,
      social_image: c.social_logo.present? && c.social_logo.image.present?,
      show_slogan: c.show_slogan,
      show_description: c.show_description
    }
  end

  def render_landing_page(default_locale:, locale_param:, structure:, cta:)
    c = community(request)

    landing_page_locale, sitename = structure["settings"].values_at("locale", "sitename")
    topbar_locale = locale_param.presence || default_locale

    initialize_i18n!(c&.id, landing_page_locale)

    # Init feature flags with marketplace specific flags, skip personal
    FeatureFlagHelper.init(community_id: c.id,
                           user_id: nil,
                           request: request,
                           is_admin: false,
                           is_marketplace_admin: false)

    props = topbar_props(c,
                         community_customization(request, landing_page_locale),
                         request.fullpath,
                         locale_param,
                         topbar_locale,
                         true)
    marketplace_context = marketplace_context(c, topbar_locale, request)


    denormalizer = build_denormalizer(
      cid: c&.id,
      cta: cta,
      locale_param: locale_param,
      default_locale: default_locale,
      landing_page_locale: landing_page_locale,
      sitename: sitename
    )

    render_to_string :landing_page,
           locals: { font_path: FONT_PATH,
                     landing_page_locale: landing_page_locale,
                     landing_page_url: "#{c.full_url}#{request.fullpath}",
                     styles: landing_page_styles,
                     javascripts: {
                       location_search: location_search_js,
                       translations: js_translations(topbar_locale)
                     },
                     topbar: {
                       enabled: true,
                       props: props,
                       marketplace_context: marketplace_context,
                       props_endpoint: ui_api_topbar_props_path(locale: topbar_locale, landing_page: true)
                     },
                     page: denormalizer.to_tree(structure, root: "page"),
                     sections: denormalizer.to_tree(structure, root: "composition"),
                     community_context: community_context(request, landing_page_locale),
                     feature_flags: FeatureFlagHelper.feature_flags,
                     asset_host: APP_CONFIG.asset_host
                   }
  end

  def render_not_found(msg = "Not found")
    self.status = 404
    self.response_body = msg
  end

  def topbar_props(community, community_customization, request_path, locale_param, topbar_locale, landing_page)
    # TopbarHelper pulls current lang from I18n
    I18n.locale = topbar_locale

    path =
      if locale_param.present?
        request_path.gsub(/^\/#{locale_param}/, "").gsub(/^\//, "")
      else
        request_path.gsub(/^\//, "")
      end

    TopbarHelper.topbar_props(
      community: community,
      path_after_locale_change: path,
      search_placeholder: community_customization&.search_placeholder,
      locale_param: locale_param,
      current_path: request_path,
      landing_page: landing_page,
      host_with_port: request.host_with_port)
  end

  # This is copied from the React on Rails source with our own rails
  # context extensions. It's repeated code and a potential source of
  # fragility. We need to address this and think if it's a good idea
  # to leverage the railsContext at all.
  def marketplace_context(community, locale, request)
    uri = Addressable::URI.parse(request.original_url)

    location = uri.path + (uri.query.present? ? "?#{uri.query}" : "")

    result = {
      # URL settings
      href: request.original_url,
      location: location,
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      pathname: uri.path,
      search: uri.query,

      # Locale settings
      i18nLocale: locale,
      i18nDefaultLocale: I18n.default_locale,
      httpAcceptLanguage: request.env["HTTP_ACCEPT_LANGUAGE"],

      # Extension(s)
      marketplaceId: community.id,
      loggedInUsername: nil
    }.merge(CommonStylesHelper.marketplace_colors(community))

    result
  end

  def facebook_locale(locale)
    I18nHelper.facebook_locale_code(Sharetribe::AVAILABLE_LOCALES, locale)
  end

  def landing_page_styles
    find_asset_path("landing_page/styles.scss")
  end

  def location_search_js
    find_asset_path("location_search.js")
  end

  def js_translations(topbar_locale)
    find_asset_path("i18n/#{topbar_locale}.js")
  end

  def find_asset_path(asset_name)
    if Rails.configuration.assets.compile
      Rails.application.assets.find_asset(asset_name)
    else
      CompassRails.sprockets.find_asset(asset_name)
    end.to_s.html_safe
  end

  def locale
    raise ArgumentError.new("You called `locale` method. This was probably a mistake. Most likely you'd want to use `landing_page_locale`, `default_locale`, or `locale_param`")
  end

  def custom_head_scripts
    FeatureFlagHelper.init(community_id: @current_community.id,
                           user_id: @current_user&.id,
                           request: request,
                           is_admin: Maybe(@current_user).is_admin?.or_else(false),
                           is_marketplace_admin: Maybe(@current_user).is_marketplace_admin?(@current_community).or_else(false))

    @current_community.custom_head_script.to_s
  end
end
