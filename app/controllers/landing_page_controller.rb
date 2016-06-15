class LandingPageController < ActionController::Metal

  LandingPageStore = CustomLandingPage::LandingPageStore

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
    version = LandingPageStore.released_version(community_id(request))
    # TODO Ideally we would do the caching based upon just clp_version
    # and avoid loading and parsing the (potentially) big structure
    # JSON.
    begin
      structure = LandingPageStore.load_structure(community_id(request), version)

      render_landing_page(structure)
    rescue CustomLandingPage::LandingPageContentNotFound
      render_not_found()
    end
  end

  def preview
    preview_version = parse_int(params[:preview_version])
    begin
      structure = LandingPageStore.load_structure(community_id(request), preview_version)

      # Uncomment for dev purposes
      # structure = JSON.parse(data_str)

      # Tell robots to not index and to not follow any links
      headers["X-Robots-Tag"] = "none"
      render_landing_page(structure)
    rescue CustomLandingPage::LandingPageContentNotFound
      render_not_found()
    end
  end


  private

  def denormalizer
    # Application paths
    paths = { "search_path" => "/search/", # FIXME. Remove hardcoded URL. Add search path here when we get one
              "signup_path" => sign_up_path }

    CustomLandingPage::Denormalizer.new(
      link_resolvers: {
        "path" => ->(type, id, normalized_data) {
          path = paths[id]

          if path.nil?
            raise ArgumentError.new("Couldn't find path '#{id}'")
          else
            {"id" => id, "path" => path}
          end
        },
        "marketplace_data" => ->(type, id, normalized_data) {
          case id
          when "primary_color"
            {"id" => "primary_color", "value" => "#347F9D"}
          end
        },
        "assets" => ->(type, id, normalized_data) {
          append_asset_path(CustomLandingPage::Denormalizer.find_link(type, id, normalized_data))
        }
      }
    )
  end

  def parse_int(int_str_or_nil)
    Integer(int_str_or_nil || "")
  rescue ArgumentError
    nil
  end

  def community_id(request)
    # TODO - This will come from request.env where the to-be-implemented middleware will put the data
    ident = request.host.split(".").first
    if ident == "aalto"
      501
    elsif ident == "oin"
      11
    end
  end

  def render_landing_page(structure)
    render :landing_page,
           locals: { font_path: "/landing_page/fonts",
                     styles: landing_page_styles,
                     javascripts: {
                       location_search: location_search_js
                     },
                     sections: denormalizer.to_tree(structure) }
  end

  def render_not_found(msg = "Not found")
    self.status = 404
    self.response_body = msg
  end

  def append_asset_path(asset)
    asset.merge("src" => ["landing_page", asset["src"]].join("/"))
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
      "id": "private_hero",
      "kind": "hero",
      "variation": "private",
      "title": "Your marketplace title goes here and it looks tasty",
      "subtitle": "Paragraph. Etiam porta sem malesuada magna mollis euismod. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sed diam.",
      "background_image": {"type": "assets", "id": "myheroimage"},
      "signup_button": "Sign up",
      "signup_path": {"type": "path", "id": "signup_path"}
    },
    {
      "id": "myhero1",
      "kind": "hero",
      "variation": "location_search",
      "title": "Your marketplace title goes here and it looks tasty",
      "subtitle": "Paragraph. Etiam porta sem malesuada magna mollis euismod. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sed diam.",
      "background_image": {"type": "assets", "id": "myheroimage"},
      "search_placeholder": "What kind of turbojopo are you looking for?",
      "search_button": "Search",
      "search_path": {"type": "path", "id": "search_path"}
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
    { "section": {"type": "sections", "id": "private_hero"},
      "disabled": false},
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
