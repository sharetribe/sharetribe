class LandingPageController < ActionController::Metal

  class Denormalizer

    def initialize(root: :composition, hooks: {})
      @root = root
      @hooks = hooks
    end

    def to_tree(normalized_data)
      root = normalized_data[@root]
      walk(root, normalized_data)
    end

    private

    def hook(type, value)
      if @hooks[type].respond_to? :call
        @hooks[type].call(value)
      else
        value
      end
    end

    def walk(obj, normalized_data)
      case obj
      when Hash
        type = obj[:type]
        id = obj[:id]

        if type.nil?
          # Not a link
          map_values(obj) { |val|
            walk(val, normalized_data)
          }
        elsif id.nil?
          # Looks like link, but no ID. That's an error.
          raise ArgumentError.new("Invalid link: #{obj.inspect} has a 'type' key but no 'id'")
        else
          # Is a link
          walk(hook(type, normalized_data[type][id]), normalized_data)
        end
      when Array
        obj.map { |x| walk(x, normalized_data) }
      else
        obj
      end
    end

    def map_values(h, &block)
      h.map { |k, v|
        [k, block.call(v)]
      }.to_h
    end
  end

  # Needed for rendering
  #
  # See Rendering Helpers: http://api.rubyonrails.org/classes/ActionController/Metal.html
  #
  include AbstractController::Rendering
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"

  def index
    landing_page
  end

  private

  def landing_page
    denormalizer = Denormalizer.new(
      hooks: {
        assets: method(:append_asset_dir)
      })

    render :landing_page, locals: { sections: denormalizer.to_tree(data) }
  end

  def append_asset_dir(file)
    ["landing_page", file].join("/")
  end

  def data
    {
      settings: {
        marketplace_id: 1234,
        locale: "en",
        sitename: "turbobikes"
      },

      sections: {
        myhero1: {
          kind: :hero,
          title: "Sell your turbobike",
          subtitle: "The best place to rent your turbojopo",
          background_image: {type: :assets, id: :myheroimage},
          search_placeholder: "What kind of turbojopo are you looking for?",
          search_button: "Search",
        },
        thecategories: {type: :categories, slogan: "blaablaa", category_ids: [123, 432, 131]},
      },

      composition: [
        { section: {type: :sections, id: :myhero1},
          disabled: false},
        { section: {type: :sections, id: :myhero1},
          disabled: false},
        { section: {type: :sections, id: :myhero1},
          disabled: true},
      ],

      assets: {
        myheroimage: "hero.png",
      }
    }
  end
end
