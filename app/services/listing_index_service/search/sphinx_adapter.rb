module ListingIndexService::Search

  class SphinxAdapter < SearchEngineAdapter

    # http://pat.github.io/thinking-sphinx/advanced_config.html
    SPHINX_MAX_MATCHES = 1000

    INCLUDE_MAP = {
      listing_images: :listing_images,
      author: :author,
      num_of_reviews: {author: :received_testimonials},
      location: :location
    }

    def search(community_id:, search:, includes:)
      included_models = includes.map { |m| INCLUDE_MAP[m] }

      # rename listing_shape_ids to singular so that Sphinx understands it
      search = HashUtils.rename_keys({:listing_shape_ids => :listing_shape_id}, search)

      if DatabaseSearchHelper.needs_db_query?(search) && DatabaseSearchHelper.needs_search?(search)
        return Result::Error.new(ArgumentError.new("Both DB query and search engine would be needed to fulfill the search"))
      end

      if DatabaseSearchHelper.needs_search?(search)
        if search_out_of_bounds?(search[:per_page], search[:page])
          DatabaseSearchHelper.success_result(0, [], includes)
        else
          search_with_sphinx(community_id: community_id,
                             search: search,
                             included_models: included_models,
                             includes: includes)
        end
      else
        DatabaseSearchHelper.fetch_from_db(community_id: community_id,
                                           search: search,
                                           included_models: included_models,
                                           includes: includes)
      end
    end

    private

    def search_with_sphinx(community_id:, search:, included_models:, includes:)
      numeric_search_fields = search[:fields].select { |f| f[:type] == :numeric_range }
      perform_numeric_search = numeric_search_fields.present?

      numeric_search_match_listing_ids =
        if numeric_search_fields.present?
          numeric_search_params = numeric_search_fields.map { |n|
            { custom_field_id: n[:id], numeric_value: n[:value] }
          }
          NumericFieldValue.search_many(numeric_search_params).collect(&:listing_id)
        else
          []
        end

      if perform_numeric_search && numeric_search_match_listing_ids.empty?
        # No matches found with the numeric search
        # Do a short circuit and return emtpy paginated collection of listings wrapped into a success result
        DatabaseSearchHelper.success_result(0, [], nil)
      else

        geo_search = parse_geo_search_params(search)

        with = HashUtils.compact(
          {
            community_id: community_id,
            category_id: search[:categories], # array of accepted ids
            listing_shape_id: search[:listing_shape_id],
            price_cents: search[:price_cents],
            listing_id: numeric_search_match_listing_ids,
            geodist: geo_search[:distance_max]
          })

        selection_groups = search[:fields].select { |v| v[:type] == :selection_group }
        grouped_by_operator = selection_groups.group_by { |v| v[:operator] }

        with_all = {
          custom_dropdown_field_options: (grouped_by_operator[:or] || []).map { |v| v[:value] },
          custom_checkbox_field_options: (grouped_by_operator[:and] || []).flat_map { |v| v[:value] },
        }

        models = Listing.search(
          Riddle::Query.escape(search[:keywords] || ""),
          sql: {
            include: included_models
          },
          page: search[:page],
          per_page: search[:per_page],
          star: true,
          with: with,
          with_all: with_all,
          order: geo_search[:order] || 'sort_date DESC',
          geo: geo_search[:origin],
          max_query_time: 1000 # Timeout and fail after 1s
        )

        begin
          distances_hash = geo_search[:origin] ? collect_geo_distances(models, search[:distance_unit]) : {}
          DatabaseSearchHelper.success_result(models.total_entries, models, includes, distances_hash)
        rescue ThinkingSphinx::SphinxError => e
          Result::Error.new(e)
        end
      end

    end

    def search_out_of_bounds?(per_page, page)
      pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
      page > pages.ceil
    end

    def selection_groups(groups)
      if groups[:search_type] == :and
        groups[:values].flatten
      else
        groups[:values]
      end
    end

    DISTANCE_UNIT_FACTORS = { miles: 1609.0, km: 1000.0 }

    def parse_geo_search_params(search)
      return {} unless search[:latitude].present? && search[:longitude].present?

      geo_params = {
        order: (search[:sort] == :distance ? 'geodist ASC' : nil),
        origin: [radians(search[:latitude]), radians(search[:longitude])]
      }

      if search[:distance_max].present?
        max_distance_meters = search[:distance_max] * DISTANCE_UNIT_FACTORS[search[:distance_unit]]
        geo_params[:distance_max] = 0..max_distance_meters
      end

      geo_params
    end

    def radians(degrees)
      degrees * Math::PI / 180
    end

    def collect_geo_distances(models, geo_unit)
      models.each_with_object({}) do |listing, result|
        # get distance from ThinkingSphinx::Search::Glaze / DistancePane
        distance = listing.distance / DISTANCE_UNIT_FACTORS[geo_unit]
        result[listing.id] = { distance_unit: geo_unit, distance: distance }
      end
    end
  end
end
