module MarketplaceHelper
  module_function

  def google_maps_key(cid)
    community_key = Community.where(id: cid).pluck(:google_maps_key).first
    community_key ? community_key : APP_CONFIG.google_maps_key
  end

  def style_customizations_map(community)
    color1 = community.custom_color1&.downcase || "a64c5d"
    color2 = community.custom_color2&.downcase || community.custom_color1&.downcase || "00a26c"

    {
      color1: color1,
      color2: color2,
      image_map: {
        cover_photo:         community.stable_image_url(:cover_photo, :hd_header),
        small_cover_photo:   community.stable_image_url(:small_cover_photo, :hd_header),
        wide_logo_lowres:    community.stable_image_url(:wide_logo, :header),
        wide_logo_highres:   community.stable_image_url(:wide_logo, :header_highres),
        square_logo_lowres:  community.stable_image_url(:logo, :header_icon),
        square_logo_highres: community.stable_image_url(:logo, :header_icon_highres),
      }
    }
  end

end
