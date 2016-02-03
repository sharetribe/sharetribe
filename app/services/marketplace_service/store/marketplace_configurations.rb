module MarketplaceService::Store::MarketplaceConfigurations

  MarketplaceConfigurationsModel = ::MarketplaceConfigurations

  MarketplaceConfigurations = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:main_search, :to_symbol, one_of: [:keyword, :location]]
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
        from_model(model)
      }
      .or_else(nil)
  end

  def get(community_id:)
    Maybe(find(community_id))
      .map { |m| from_model(m) }
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

end
