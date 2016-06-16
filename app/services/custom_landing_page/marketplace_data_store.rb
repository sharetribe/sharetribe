module CustomLandingPage
  module MarketplaceDataStore

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

      { "primary_color" => primary_color.present? ? "#" + primary_color : nil,
        "name" => name,
        "slogan" => slogan,
        "description" => description,
        "search_type" => search_type,
        "search_placeholder" => search_placeholder
      }
    end
  end
end
