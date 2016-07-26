module SettingsViewUtils
  extend ActionView::Helpers::TranslationHelper

  module_function

  def search_type_translation(search_type)
    case search_type
    when :keyword
      t("admin.communities.settings.keyword_search")
    when :location
      t("admin.communities.settings.location_search")
    when :keyword_and_location
      t("admin.communities.settings.keyword_and_location_search")
    else
      raise("Unknown search type: #{search_type}")
    end
  end

  def distance_unit_translation(distance_unit)
    case distance_unit
    when :km
      t("admin.communities.settings.km")
    when :miles
      t("admin.communities.settings.miles")
    else
      raise("Unknown distance unit: #{distance_unit}")
    end
  end

end