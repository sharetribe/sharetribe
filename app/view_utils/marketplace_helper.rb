module MarketplaceHelper
  module_function

  def google_maps_key(cid)
    community_key = Community.where(id: cid).pluck(:google_maps_key).first
    community_key ? community_key : APP_CONFIG.google_maps_key
  end

  def style_customizations_map(community)
    # get colors from helper, but strip # prefix
    color1, color2, slogan_color, description_color = CommonStylesHelper.marketplace_colors(community).map{ |k, v| v[1..-1] }

    {
      color1: color1,
      color2: color2,
      slogancolor: slogan_color,
      descriptioncolor: description_color,
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
