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
          { "id" => id, "type" => type, "path" => path }
        end
      end
    end

    class MarketplaceDataResolver
      def initialize(data)
        @_data = data
      end

      def call(type, id, _)
        unless @_data.key?(id)
          raise LinkResolvingError.new("Unknown marketplace data value '#{id}'.")
        end

        value = @_data[id]
        { "id" => id, "type" => type, "value" => value }
      end
    end

    class AssetResolver
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
        asset.merge("src" => ["landing_page", asset["src"]].join("/"))
      end
    end
  end
end
