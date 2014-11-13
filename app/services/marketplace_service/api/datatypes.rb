module MarketplaceService::API::DataTypes

  Marketplace = EntityUtils.define_builder(
    [:id, :mandatory, :fixnum],
    [:url, :mandatory, :string]
  )
end
