module MarketplaceService::API
  class Api

    class << self
      attr_accessor(
        :configurations_api
      )
    end

    def self.configurations
      self.configurations_api ||= MarketplaceService::API::Configurations.new
    end
  end
end
