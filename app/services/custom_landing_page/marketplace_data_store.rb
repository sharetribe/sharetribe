module CustomLandingPage
  module MarketplaceDataStore

    DEFAULT_COLOR = "A64C5D"

    module_function

    def marketplace_data(cid, locale)
      primary_color, private = Community.where(id: cid)
                               .pluck(:custom_color1, :private)
                               .first

      name,
      slogan,
      description,
      search_placeholder = CommunityCustomization
                           .where(community_id: cid, locale: locale)
                           .pluck(:name, :slogan, :description, :search_placeholder)
                           .first

      search_placeholder ||= I18n.t("landing_page.hero.search_placeholder", locale: locale)

      main_search = MarketplaceConfigurations
                    .where(community_id: cid)
                    .pluck(:main_search)
                    .first

      search_type =
        if private
          "private"
        elsif main_search == "location"
          "location_search"
        else
          "keyword_search"
        end

      color = primary_color.present? ? primary_color : DEFAULT_COLOR
      color_darken = ColorUtils.darken(color, 15)

      { "primary_color" => ColorUtils.css_to_rgb_array(color),
        "primary_color_darken" => ColorUtils.css_to_rgb_array(color_darken),
        "name" => name,
        "slogan" => slogan,
        "description" => description,
        "search_type" => search_type,
        "search_placeholder" => search_placeholder
      }
    end
  end
end
