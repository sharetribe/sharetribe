# rubocop:disable ClassLength

class LandingPageController < ActionController::Metal

  CLP = CustomLandingPage

  # Needed for rendering
  #
  # See Rendering Helpers: http://api.rubyonrails.org/classes/ActionController/Metal.html
  #
  include AbstractController::Rendering
  include ActionController::ConditionalGet
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"

  # Include route helpers
  include Rails.application.routes.url_helpers

  # Adds helper_method
  include ActionController::Helpers

  CACHE_TIME = APP_CONFIG[:clp_cache_time].to_i.seconds
  CACHE_HEADER = "X-CLP-Cache"

  def index
    cid = community_id(request)
    default_locale = community_default_locale(request)
    version = CLP::LandingPageStore.released_version(cid)
    locale_param = params[:locale]

    begin
      content = nil
      cache_meta = fetch_cache_meta(cid, version, locale_param)
      cache_hit = true

      if cache_meta.nil?
        cache_hit = false
        content = build_html(
          community_id: cid,
          default_locale: default_locale,
          locale_param: locale_param,
          version: version
        )
        cache_meta = build_cache_meta(content)

        # write metadata first, so that it expires first
        write_cache_meta!(cid, version, locale_param, cache_meta, CACHE_TIME)
        # cache html longer than metadata, but keyed by content (digest)
        write_cached_content!(cid, version, content, cache_meta[:digest], CACHE_TIME + 10.seconds)
      end

      if stale?(etag: cache_meta[:digest],
                last_modified: cache_meta[:last_modified],
                template: false,
                public: true)

        content = fetch_cached_content(cid, version, cache_meta[:digest])
        if content.nil?
          # This should not happen since html is cached longer than metadata
          cache_hit = false
          content = build_html(
            community_id: cid,
            default_locale: default_locale,
            locale_param: locale_param,
            version: version
          )
        end

        self.status = 200
        self.response_body = content
      end
      # There's an implicit else here because stale? has the
      # side-effect of setting response to HEAD 304 if we have a match
      # for conditional get.

      headers[CACHE_HEADER] = cache_hit ? "1" : "0"
      expires_in(CACHE_TIME, public: true)
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end

  def preview
    cid = community_id(request)
    default_locale = community_default_locale(request)
    preview_version = parse_int(params[:preview_version])
    locale_param = params[:locale]

    begin
      structure = CLP::LandingPageStore.load_structure(cid, preview_version)

      # Uncomment for dev purposes
      # structure = JSON.parse(data_str)

      # Tell robots to not index and to not follow any links
      headers["X-Robots-Tag"] = "none"

      self.status = 200
      self.response_body = render_landing_page(
        community_id: cid,
        default_locale: default_locale,
        locale_param: locale_param,
        structure: structure
      )
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end


  private

  def build_html(community_id:, default_locale:, locale_param:, version:)
    structure = CLP::LandingPageStore.load_structure(community_id, version)
    render_landing_page(
      community_id: community_id,
      default_locale: default_locale,
      structure: structure,
      locale_param: locale_param
    )
  end

  def build_cache_meta(content)
    {last_modified: Time.now(), digest: Digest::MD5.hexdigest(content)}
  end

  def fetch_cache_meta(community_id, version, locale)
    Rails.cache.read("clp/#{community_id}/#{version}/#{locale}")
  end

  def write_cache_meta!(community_id, version, locale, cache_meta, cache_time)
    Rails.cache.write("clp/#{community_id}/#{version}/#{locale}", cache_meta, expires_in: cache_time)
  end

  def fetch_cached_content(community_id, version, digest)
    Rails.cache.read("clp/#{community_id}/#{version}/#{digest}")
  end

  def write_cached_content!(community_id, version, content, digest, cache_time)
    Rails.cache.write("clp/#{community_id}/#{version}/#{digest}", content, expires_in: cache_time)
  end

  def build_denormalizer(cid:, default_locale:, locale_param:, sitename:)
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
    paths = { "search" => search_path.call(),
              "all_categories" => search_path.call(category: "all"),
              "signup" => sign_up_path(locale: locale_param),
              "about" => about_infos_path(locale: locale_param),
              "contact_us" => new_user_feedback_path(locale: locale_param),
              "post_a_new_listing" => new_listing_path(locale: locale_param)
            }

    marketplace_data = CLP::MarketplaceDataStore.marketplace_data(cid, locale)

    build_category_path = ->(category_name_param) {
      search_path.call(category: category_name_param)
    }

    CLP::Denormalizer.new(
      link_resolvers: {
        "path" => CLP::LinkResolver::PathResolver.new(paths),
        "marketplace_data" => CLP::LinkResolver::MarketplaceDataResolver.new(marketplace_data),
        "assets" => CLP::LinkResolver::AssetResolver.new(APP_CONFIG[:clp_asset_host], sitename),
        "translation" => CLP::LinkResolver::TranslationResolver.new(locale),
        "category" => CLP::LinkResolver::CategoryResolver.new(cid, locale, build_category_path)
      }
    )
  end

  def parse_int(int_str_or_nil)
    Integer(int_str_or_nil || "")
  rescue ArgumentError
    nil
  end

  def community_id(request)
    request.env[:current_marketplace]&.id
  end

  def community_default_locale(request)
    request.env[:current_marketplace]&.default_locale
  end

  def render_landing_page(community_id:, default_locale:, locale_param:, structure:)
    locale, sitename = structure["settings"].values_at("locale", "sitename")
    font_path = APP_CONFIG[:font_proximanovasoft_url].present? ? APP_CONFIG[:font_proximanovasoft_url] : "/landing_page/fonts"

    denormalizer = build_denormalizer(
      cid: community_id,
      locale_param: locale_param,
      default_locale: default_locale,
      sitename: sitename
    )

    render_to_string :landing_page,
           locals: { font_path: font_path,
                     styles: landing_page_styles,
                     javascripts: {
                       location_search: location_search_js
                     },
                     page: denormalizer.to_tree(structure, root: "page"),
                     sections: denormalizer.to_tree(structure, root: "composition") }
  end

  def render_not_found(msg = "Not found")
    self.status = 404
    self.response_body = msg
  end

  # rubocop:disable Metrics/MethodLength
  def data_str
    <<JSON
{
  "settings": {
    "marketplace_id": 9999,
    "locale": "en",
    "sitename": "turbobikes"
  },

  "page": {
    "title": {"type": "marketplace_data", "id": "name"}
  },

  "sections": [
    {
      "id": "myhero1",
      "kind": "hero",
      "variation": {"type": "marketplace_data", "id": "search_type"},
      "title": {"type": "marketplace_data", "id": "slogan"},
      "subtitle": {"type": "marketplace_data", "id": "description"},
      "background_image": {"type": "assets", "id": "myheroimage"},
      "search_button": {"type": "translation", "id": "search_button"},
      "search_path": {"type": "path", "id": "search"},
      "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
      "signup_path": {"type": "path", "id": "signup"},
      "signup_button": {"type": "translation", "id": "signup_button"},
      "search_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "search_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "signup_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "signup_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"}
    },
    {
      "id": "categories7",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "Mountain bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "type": "category",
            "id": 1
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "Parts",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories6",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "Mountain bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories5",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories4",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories3",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "info1_v1",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V1]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",

      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Section link",
      "button_path": {"type": "path", "id": "post_a_new_listing"},
      "background_image": {"type": "assets", "id": "myinfoimage"}
    },
    {
      "id": "info1_v2",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V2]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "background_image": {"type": "assets", "id": "myinfoimage2"}
    },
    {
      "id": "info1_v3",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V3]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Section link",
      "button_path": {"value": "https://google.com"}
    },
    {
      "id": "info1_v4",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V4]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero."
    },
    {
      "id": "info2_v1",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V1]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "globe-1",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info2_v2",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V2]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info2_v3",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V3]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "icon": "globe-1",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "info2_v4",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V4]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "info3_v1",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V1]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info3_v2",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V2]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info3_v3",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V3]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        }
      ]
    },
    {
      "id": "info3_v4",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V4]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        }
      ]
    },
    {
      "id": "footer",
      "kind": "footer",
      "theme": "dark",
      "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "social_media_icon_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "links": [
        {"label": "About", "href": {"type": "path", "id": "about"}},
        {"label": "Contact us", "href": {"type": "path", "id": "contact_us"}},
        {"label": "Sharetribe", "href": {"value": "https://www.sharetribe.com"}}
      ],
      "social": [
        {"service": "facebook", "url": "https://www.facebook.com"},
        {"service": "twitter", "url": "https://www.twitter.com"},
        {"service": "instagram", "url": "https://www.instagram.com"}
      ],
      "copyright": "Copyright Marketplace Ltd 2016"
    },

    {
      "id": "thecategories",
      "kind": "categories",
      "slogan": "blaablaa",
      "category_ids": [123, 432, 131]
    }
  ],

  "composition": [
    { "section": {"type": "sections", "id": "myhero1"}},
    { "section": {"type": "sections", "id": "categories7"}},
    { "section": {"type": "sections", "id": "categories6"}},
    { "section": {"type": "sections", "id": "categories5"}},
    { "section": {"type": "sections", "id": "categories4"}},
    { "section": {"type": "sections", "id": "categories3"}},
    { "section": {"type": "sections", "id": "info1_v1"}},
    { "section": {"type": "sections", "id": "info1_v2"}},
    { "section": {"type": "sections", "id": "info1_v3"}},
    { "section": {"type": "sections", "id": "info1_v4"}},
    { "section": {"type": "sections", "id": "info2_v1"}},
    { "section": {"type": "sections", "id": "info2_v2"}},
    { "section": {"type": "sections", "id": "info2_v3"}},
    { "section": {"type": "sections", "id": "info2_v4"}},
    { "section": {"type": "sections", "id": "info3_v1"}},
    { "section": {"type": "sections", "id": "info3_v2"}},
    { "section": {"type": "sections", "id": "info3_v3"}},
    { "section": {"type": "sections", "id": "info3_v4"}},
    { "section": {"type": "sections", "id": "footer"}}
  ],

  "assets": [
    { "id": "myheroimage", "src": "hero.jpg" },
    { "id": "myinfoimage", "src": "info.jpg" },
    { "id": "myinfoimage2", "src": "church.jpg" }
  ]
}
JSON
  end
  # rubocop:enable Metrics/MethodLength

  def landing_page_styles
    Rails.application.assets.find_asset("landing_page/styles.scss").to_s.html_safe
  end

  def location_search_js
    Rails.application.assets.find_asset("location_search.js").to_s.html_safe
  end
end
