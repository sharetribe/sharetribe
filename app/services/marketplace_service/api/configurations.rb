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

    # Usage:
    # update({
    #   community_id: 1,                # <community_id>,
    #   configurations: {
    #     main_search: :keyword,        # optional, one of: :keyword, :location, :keyword_and_location
    #     distance_unit: :metric,       # optional, one of: :metric, :imperial
    #     limit_search_distance: false, # optional, boolean
    #     limit_priority_links: 4,      # optional, -1..5
    #   }
    # })
    def update(community_id:, configurations:)
      current_confs = Maybe(ConfigurationsStore.get(community_id: community_id)).or_else(community_id: community_id)
      configs = current_confs.merge(configurations)

      Maybe(ConfigurationsStore.update(configs))
        .map { |confs|
          Result::Success.new(confs)
        }
        .or_else {
          Result::Error.new("Cannot update marketplace configurations for community id: #{community_id}")
        }
    end

  end
end