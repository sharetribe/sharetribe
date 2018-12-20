module CustomLandingPage
  module MarketplaceDataStore

    DEFAULT_COLOR = "4a90e2"

    module_function

    def marketplace_data(cid, locale)
      primary_color,
      twitter_handle,
      name_display_type = Community.where(id: cid)
                          .pluck(:custom_color1, :twitter_handle, :name_display_type)
                          .first

      name,
      slogan,
      description,
      search_placeholder,
      social_media_title,
      social_media_description = CommunityCustomization
                                 .where(community_id: cid, locale: locale)
                                 .pluck(:name, :slogan, :description, :search_placeholder, :social_media_title, :social_media_description)
                                 .first

      slogan             ||= I18n.t("common.default_community_slogan", locale: locale)
      description        ||= I18n.t("common.default_community_description", locale: locale)
      search_placeholder ||= I18n.t("landing_page.hero.search_placeholder", locale: locale)
      social_media_title ||= "#{name} - #{slogan}"
      social_media_description ||= description

      # In :keyword_and_location mode, we use fixed translation for location input.
      search_location_with_keyword_placeholder = I18n.t("landing_page.hero.search_location_placeholder", locale: locale)

      main_search = MarketplaceConfigurations
                    .where(community_id: cid)
                    .pluck(:main_search)
                    .first

      search_type =
        if main_search == "keyword_and_location"
          "keyword_and_location_search"
        elsif main_search == "location"
          "location_search"
        else
          "keyword_search"
        end

      color = primary_color.present? ? primary_color : DEFAULT_COLOR
      color_darken = ColorUtils.brightness(color, 85)

      slogan = split_long_words(slogan)
      description = split_long_words(description)

      { "primary_color" => ColorUtils.css_to_rgb_array(color),
        "primary_color_darken" => ColorUtils.css_to_rgb_array(color_darken),
        "name" => name,
        "slogan" => slogan,
        "page_title" => "#{name} - #{slogan}",
        "description" => description,
        "search_type" => search_type,
        "search_placeholder" => search_placeholder,
        "search_location_with_keyword_placeholder" => search_location_with_keyword_placeholder,
        "twitter_handle" => twitter_handle,
        "name_display_type" => name_display_type,
        "social_media_title" => social_media_title,
        "social_media_description" => social_media_description
      }
    end

    UNICODE_ZERO_WIDTH_SPACE = "\u200b"

    def split_long_words(value)
      value.to_s.gsub(/\S{18,}/){ |word| word.split(//).join(UNICODE_ZERO_WIDTH_SPACE) }
    end
  end
end
