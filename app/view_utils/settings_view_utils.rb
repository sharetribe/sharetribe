module SettingsViewUtils
  extend ActionView::Helpers::TranslationHelper

  module_function

  def search_type_translation(search_type)
    case search_type
    when :keyword
      t("admin.communities.settings.keyword_search")
    when :location
      t("admin.communities.settings.location_search")
    else
      raise("Unknown search type: #{search_type}")
    end
  end

end