module ListingService::API
  class Api
    class << self
      attr_accessor(
        :shapes_api
      )
    end

    def self.shapes
      self.shapes_api ||= ListingService::API::Shapes.new
    end
  end
end
