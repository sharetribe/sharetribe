module MarketplaceService::Store::MarketplaceConfigurations

  MarketplaceConfigurationsModel = ::MarketplaceConfigurations

  MarketplaceConfigurations = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:main_search, :to_symbol, one_of: [:keyword, :location]],
    [:distance_unit, :to_symbol, one_of: [:metric, :imperial]]
  )

  module_function

  def create(opts)
    settings = HashUtils.compact(MarketplaceConfigurations.call(opts))
    model = MarketplaceConfigurationsModel.create!(settings)
    from_model(model)
  end

  def update(opts)
    settings = MarketplaceConfigurations.call(opts)

    Maybe(find(opts[:community_id]))
      .map { |model|
        model.update_attributes!(settings)
        invalidate_cache(opts[:community_id])
        from_model(model)
      }
      .or_else(nil)
  end

  def get(community_id:)
    Maybe(configurations_cache(community_id))
      .or_else(nil)
  end


  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m| EntityUtils.model_to_hash(m) }
      .map { |hash| MarketplaceConfigurations.call(hash) }
      .or_else(nil)
  end

  def find(community_id)
    MarketplaceConfigurationsModel.where(community_id: community_id).first
  end


  def configurations_cache(community_id)
    Rails.cache.fetch(cache_key(community_id)) do
      from_model(find(community_id))
    end
  end

  def cache_key(community_id)
    "/marketplace_service/configurations/community/#{community_id}"
  end

  def invalidate_cache(community_id)
    Rails.cache.delete(cache_key(community_id))
  end


end
