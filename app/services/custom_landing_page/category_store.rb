module CustomLandingPage
  module CategoryStore

    module_function

    # Returns categories in Hash (for fast and easy access)
    #
    # Example:
    #
    # { 1 => { "title" => "Category 1", ... },
    #   2 => { "title" => "Category 1", ... }
    # }
    #
    def categories(cid, locale, search_path)
      Category.where(community_id: cid).map { |category|
        data = {
          "title" => category.display_name(locale),
          "path" => search_path.call(category: category.url)
        }

        [category.id, data]
      }.to_h
    end

    # private

    def paths
      @_url_helpers ||= Rails.application.routes.url_helpers
    end
  end
end
