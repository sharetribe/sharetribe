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
        cover_photo:         community.cover_photo.url(:hd_header),
        small_cover_photo:   community.small_cover_photo.url(:hd_header),
        wide_logo_lowres:    community.wide_logo.url(:header),
        wide_logo_highres:   community.wide_logo.url(:header_highres),
        square_logo_lowres:  community.logo.url(:header_icon),
        square_logo_highres: community.logo.url(:header_icon_highres),
      }
    }
  end

end
