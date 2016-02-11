module MarketplaceService::API

  ConfigurationsStore = MarketplaceService::Store::MarketplaceConfigurations

  class Configurations

    def get(community_id:)
      Maybe(ConfigurationsStore.get(community_id: community_id))
        .map { |configurations|
          Result::Success.new(configurations)
        }
        .or_else {
          Result::Error.new("Cannot find marketplace configurations for community id: #{community_id}")
        }
    end

    def update(community_id:, main_search:, distance_unit:)
      Maybe(ConfigurationsStore.update(community_id: community_id, main_search: main_search, distance_unit: distance_unit))
        .map { |configurations|
          Result::Success.new(configurations)
        }
        .or_else {
          Result::Error.new("Cannot update marketplace configurations for community id: #{community_id}")
        }
    end

  end
end