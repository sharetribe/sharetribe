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
      structure = CLP::LandingPageStore.load_structure(cid, preview_version)

      # Uncomment for dev purposes
      # structure = JSON.parse(data_str)

      # Tell robots to not index and to not follow any links
      headers["X-Robots-Tag"] = "none"
      render_landing_page(cid, structure)
    rescue CLP::LandingPageContentNotFound
      render_not_found()
    end
  end


  private

  def denormalizer(cid, locale, sitename)
    # Application paths
    paths = { "search_path" => "/", # FIXME. Remove hardcoded URL. Add search path here when we get one
              "signup_path" => sign_up_path }

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

    render :landing_page,
           locals: { font_path: "/landing_page/fonts",
                     styles: landing_page_styles,
                     javascripts: {
                       location_search: location_search_js
                     },
                     sections: denormalizer(cid, locale, sitename).to_tree(structure) }
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

  "sections": [
    {
      "id": "myhero1",
      "kind": "hero",
      "variation": {"type": "marketplace_data", "id": "search_type"},
      "title": {"type": "marketplace_data", "id": "slogan"},
      "subtitle": {"type": "marketplace_data", "id": "description"},
      "background_image": {"type": "assets", "id": "myheroimage"},
      "search_button": {"type": "translation", "id": "search_button"},
      "search_path": {"type": "path", "id": "search_path"},
      "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
      "signup_path": {"type": "path", "id": "signup_path"},
      "signup_button": {"type": "translation", "id": "signup_button"}
    },
    {
      "id": "footer",
      "kind": "footer",
      "theme": "dark",
      "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "links": [
        {"label": "About", "url": "/about"},
        {"label": "How it works", "url": "https://www.google.com"},
        {"label": "Blog", "url": "/about"},
        {"label": "Contact", "url": "https://www.google.com"},
        {"label": "FAQ", "url": "/about"}
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
    { "section": {"type": "sections", "id": "footer"},
      "disabled": false},
    { "section": {"type": "sections", "id": "myhero1"},
      "disabled": false},
    { "section": {"type": "sections", "id": "myhero1"},
      "disabled": true}
  ],

  "assets": [
    {
      "id": "myheroimage",
      "src": "hero.jpg"
    }
  ]
}
JSON
  end

  def landing_page_styles
    Rails.application.assets.find_asset("landing_page/styles.scss").to_s
  end

  def location_search_js
    Rails.application.assets.find_asset("location_search.js").to_s.html_safe
  end
end
