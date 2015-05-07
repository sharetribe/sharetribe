module ListingService::API
  class Api
    class << self
      attr_accessor(
        :shapes_api,
        :categories_api,
        :listings_api
      )
    end

    def self.shapes
      self.shapes_api ||= ListingService::API::Shapes.new
    end

    def self.categories
      self.categories_api ||= ListingService::API::Categories.new
    end

    def self.listings
      self.listings_api ||= ListingService::API::Listings.new
    end
  end
end
