module MarketplaceHelper
  module_function

  def google_maps_key(cid)
    community_key = Community.where(id: cid).pluck(:google_maps_key).first
    community_key ? community_key : APP_CONFIG.google_maps_key
  end

end
