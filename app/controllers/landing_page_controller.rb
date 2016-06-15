class LandingPageController < ActionController::Metal

  CLP = CustomLandingPage

  # Needed for rendering
  #
  # See Rendering Helpers: http://api.rubyonrails.org/classes/ActionController/Metal.html
  #
  include AbstractController::Rendering
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"

  # Include route helpers
  include Rails.application.routes.url_helpers

  # Adds helper_method
  include ActionController::Helpers

  def index
    cid = community_id(request)
    version = CLP::LandingPageStore.released_version(cid)

    # TODO Ideally we would do the caching based upon just clp_version
    # and avoid loading and parsing the (potentially) big structure
    # JSON.
    begin
      structure = CLP::LandingPageStore.load_structure(cid, version)

      render_landing_page(cid, structure)
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end

  def preview
    cid = community_id(request)
    preview_version = parse_int(params[:preview_version])

    begin
      # structure = CLP::LandingPageStore.load_structure(cid, preview_version)

      # Uncomment for dev purposes
      structure = JSON.parse(data_str)

      # Tell robots to not index and to not follow any links
      headers["X-Robots-Tag"] = "none"
      render_landing_page(cid, structure)
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end


  private

  def build_denormalizer(cid, locale, sitename)
    # Application paths
    paths = { "search" => "/", # FIXME. Remove hardcoded URL. Add search path here when we get one
              "signup" => sign_up_path,
              "about" => about_infos_path,
              "contact_us" => new_user_feedback_path
            }

    marketplace_data = CLP::MarketplaceDataStore.marketplace_data(cid, locale)

    CLP::Denormalizer.new(
      link_resolvers: {
        "path" => CLP::LinkResolver::PathResolver.new(paths),
        "marketplace_data" => CLP::LinkResolver::MarketplaceDataResolver.new(marketplace_data),
        "assets" => CLP::LinkResolver::AssetResolver.new(APP_CONFIG[:clp_asset_host], sitename),
        "translation" => CLP::LinkResolver::TranslationResolver.new(locale)
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

  def render_landing_page(cid, structure)
    locale, sitename = structure["settings"].values_at("locale", "sitename")
    font_path = APP_CONFIG[:font_proximanovasoft_url].present? ? APP_CONFIG[:font_proximanovasoft_url] : "/landing_page/fonts"

    denormalizer = build_denormalizer(cid, locale, sitename)

    render :landing_page,
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
      "id": "info",
      "kind": "info",
      "variation": "one_column",
      "title": "Section title goes here",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "button": {
        "title": "Section link",
        "path": {"path": "https://google.com"},
        "color": {"type": "marketplace_data", "id": "primary_color"}
      },
      "background_image": {"type": "assets", "id": "myinfoimage"}
    },
    {
      "id": "info2",
      "kind": "info",
      "variation": "one_column",
      "title": "Section title goes here",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "background_image": {"type": "assets", "id": "myinfoimage2"}
    },
    {
      "id": "info3",
      "kind": "info",
      "variation": "one_column",
      "title": "Section title goes here",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "button": {
        "title": "Section link",
        "path": {"path": "https://google.com"},
        "color": {"type": "marketplace_data", "id": "primary_color"}
      }
    },
    {
      "id": "info4",
      "kind": "info",
      "variation": "one_column",
      "title": "Section title goes here",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero."
    },
    {
      "id": "info5",
      "kind": "info",
      "variation": "three_columns",
      "title": "Section title goes here",
      "icons": true,
      "buttons": true,
      "columns": [
        {
          "icon": "feather",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"path": "https://google.com"},
          "button_color": {"type": "marketplace_data", "id": "primary_color"}
        },
        {
          "icon": "piggybank",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"path": "https://google.com"},
          "button_color": {"type": "marketplace_data", "id": "primary_color"}
        },
        {
          "icon": "globe",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"path": "https://google.com"},
          "button_color": {"type": "marketplace_data", "id": "primary_color"}
        }
      ]
    },
    {
      "id": "footer",
      "kind": "footer",
      "theme": "light",
      "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "social_media_icon_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "links": [
        {"label": "About", "href": {"type": "path", "id": "about"}},
        {"label": "Contact us", "href": {"type": "path", "id": "contact_us"}},
        {"label": "Sharetribe", "href": {"path": "https://www.sharetribe.com"}}
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
    { "section": {"type": "sections", "id": "info"}},
    { "section": {"type": "sections", "id": "info2"}},
    { "section": {"type": "sections", "id": "info3"}},
    { "section": {"type": "sections", "id": "info4"}},
    { "section": {"type": "sections", "id": "info5"}},
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

  def landing_page_styles
    Rails.application.assets.find_asset("landing_page/styles.scss").to_s.html_safe
  end

  def location_search_js
    Rails.application.assets.find_asset("location_search.js").to_s.html_safe
  end
end
