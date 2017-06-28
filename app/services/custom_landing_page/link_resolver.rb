module CustomLandingPage
  module LinkResolver

    class LinkResolvingError < StandardError; end

    class PathResolver
      def initialize(paths)
        @_paths = paths
      end

      def call(type, id, _)
        path = @_paths[id]

        if path.nil?
          raise LinkResolvingError.new("Couldn't find path '#{id}'.")
        else
          { "id" => id, "type" => type, "value" => path }
        end
      end
    end

    class MarketplaceDataResolver
      def initialize(data, cta)
        @_data = data
        @_cta = cta
      end

      def call(type, id, _)
        unless @_data.key?(id)
          raise LinkResolvingError.new("Unknown marketplace data value '#{id}'.")
        end

        value =
          case id
          when "search_type"
            search_type
          else
            value = @_data[id]
          end

        { "id" => id, "type" => type, "value" => value }
      end

      def search_type
        case @_cta
        when "signup"
          "private"
        else
          @_data["search_type"]
        end
      end
    end

    class AssetResolver
      def initialize(asset_url, sitename)
        unless sitename.present?
          raise CustomLandingPage::LandingPageConfigurationError.new("Missing sitename.")
        end

        @_asset_url = asset_url
        @_sitename = sitename
      end

      def call(type, id, normalized_data)
        asset = normalized_data[type].find { |item| item["id"] == id }

        if asset.nil?
          raise LinkResolvingError.new("Unable to find an asset with id '#{id}'.")
        else
          append_asset_path(asset)
        end
      end


      private

      def append_asset_path(asset)
        host = @_asset_url || ""
        src = URLUtils.join(@_asset_url, asset["src"]).sub("%{sitename}", @_sitename)

        asset.merge("src" => src)
      end
    end

    class TranslationResolver
      def initialize(locale)
        @_locale = locale
      end

      def call(type, id, _)
        translation_keys = {
          "search_button" => "landing_page.hero.search",
          "signup_button" => "landing_page.hero.signup",
          "no_listing_image" => "landing_page.listings.no_listing_image"
        }

        key = translation_keys[id]

        raise LinkResolvingError.new("Couldn't find translation key for '#{id}'.") if key.nil?

        value = I18n.translate(key, locale: @_locale)

        if value.nil?
          raise LinkResolvingError.new("Unknown translation for key '#{key}' and locale '#{locale}'.")
        else
          { "id" => id, "type" => type, "value" => value }
        end
      end
    end

    class CategoryResolver
      def initialize(data)
        @_data = data
      end

      def call(type, id, _)
        if @_data.key?(id)
          @_data[id].merge("id" => id, "type" => type)
        end
      end
    end

    class ListingResolver
      def initialize(cid, landing_page_locale, locale_param, name_display_type)
        @_cid = cid
        @_landing_page_locale = landing_page_locale
        @_locale_param = locale_param
        @_name_display_type = name_display_type
      end

      def call(type, id, _)
        ListingStore.listing(id: id,
                             community_id: @_cid,
                             landing_page_locale: @_landing_page_locale,
                             locale_param: @_locale_param,
                             name_display_type: @_name_display_type)
      end

    end
  end
end
