module ListingIndexService::API
  class Api
    class << self
      attr_accessor(
        :listings_api
      )
    end

    def self.listings
      self.listings_api ||= ListingIndexService::API::Listings.new(Rails.logger)
    end
  end
end
