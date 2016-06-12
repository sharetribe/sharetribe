class LandingPageController < ActionController::Metal

  class Denormalizer

    def initialize(root: "composition", link_resolvers: {})
      @root = root
      @link_resolvers = link_resolvers
    end

    def to_tree(normalized_data)
      root = normalized_data[@root]

      deep_map(root) { |k, v|
        case v
        when Hash
          type, id = v.values_at("type", "id")

          new_v =
            if type.nil?
              # Not a link
              v
            elsif id.nil?
              # Looks like link, but no ID. That's an error.
              raise ArgumentError.new("Invalid link: #{v.inspect} has a 'type' key but no 'id'")
            else
              # Is a link
              resolve_link(type, id, normalized_data)
            end

          [k, new_v]
        else
          [k, v]
        end
      }
    end

    # Recursively walks through nested hash and performs `map` operation.
    #
    # The tree is traversed in pre-order manner.
    #
    # In each node, calls the block with two arguments: key and value.
    # The block needs to return a tuple of [key, value].
    #
    # Example (double all values):
    #
    # deep_map(a: { b: { c: 1}, d: [{ e: 1, f: 2 }]}) { |k, v|
    #   [k, v * 2]
    # }
    #
    #
    # Example (stringify keys):
    #
    # deep_map(a: 1, b: 2) { |k, v|
    #   [k.to_s, v]
    # }
    #
    # Unlike Ruby's Hash#map, this method returns a Hash, not an Array.
    #
    def deep_map(obj, &block)
      case obj
      when Hash
        obj.map { |k, v|
          deep_map(block.call(k, v), &block)
        }.to_h
      when Array
        obj.map { |x| deep_map(x, &block) }
      else
        obj
      end
    end

    def self.find_link(type, id, normalized_data)
      normalized_data[type].find { |item| item["id"] == id }
    end

    private

    def resolve_link(type, id, normalized_data)
      if @link_resolvers[type].respond_to? :call
        @link_resolvers[type].call(type, id, normalized_data)
      else
        self.class.find_link(type, id, normalized_data)
      end
    end
  end

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
    landing_page
  end

  private

  def landing_page
    denormalizer = Denormalizer.new()

    # Application paths
    paths = {
      search_path: "/search/", # FIXME. Remove hardcoded URL. Add search path here when we get one
      signup_path: sign_up_path
    }

    # Environment specific paths
    environment = {
      font_path: "/landing_page/fonts",
      user_image_path: "/landing_page"
    }

    render :landing_page, locals: {
             styles: landing_page_styles,
             sections: denormalizer.to_tree(data),
             paths: paths,
             environment: environment
           }
  end

  def data
    {
      "settings" => {
        "marketplace_id" => 9999,
        "locale" => "en",
        "sitename" => "turbobikes"
      },

      "sections" => [
        {
          "id" => "private_hero",
          "kind" => "hero",
          "variation" => "private",
          "title" => "Your marketplace title goes here and it looks tasty",
          "subtitle" => "Paragraph. Etiam porta sem malesuada magna mollis euismod. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sed diam.",
          "background_image" => {"type" => "assets", "id" => "myheroimage"},
          "signup_button" => "Sign up"
        },

        {
          "id" => "myhero1",
          "kind" => "hero",
          "variation" => "keyword_search",
          "title" => "Your marketplace title goes here and it looks tasty",
          "subtitle" => "Paragraph. Etiam porta sem malesuada magna mollis euismod. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas sed diam.",
          "background_image" => {"type" => "assets", "id" => "myheroimage"},
          "search_placeholder" => "What kind of turbojopo are you looking for?",
          "search_button" => "Search",
        },

        {
          "id" => "thecategories",
          "kind" => "categories",
          "slogan" => "blaablaa",
          "category_ids" => [123, 432, 131]
        },
      ],

      "composition" => [
        { "section" => {"type" => "sections", "id" => "private_hero"},
          "disabled" => false},
        { "section" => {"type" => "sections", "id" => "myhero1"},
          "disabled" => true},
        { "section" => {"type" => "sections", "id" => "myhero1"},
          "disabled" => true},
      ],

      "assets" => [
        {
          "id" => "myheroimage",
          "src" => "hero.jpg",
        }
      ]
    }
  end


  def landing_page_styles
    Rails.application.assets.find_asset("landing_page/styles.scss").to_s
  end
end
