module MarketplaceService::API::DataTypes

  Marketplace = EntityUtils.define_builder(
    [:id, :mandatory, :fixnum],
    [:domain, :mandatory, :string],
    [:url, :mandatory, :string],
    [:locales, :mandatory, :enumerable],
    [:country, :string],
    [:available_currencies, :string],
  )


  module_function

  def create_marketplace(opts); Marketplace.call(opts) end
end
