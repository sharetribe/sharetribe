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

      if needs_db_query?(search) && needs_search?(search)
        raise ArgumentError.new("Both DB query and search engine would be needed to full fill the search")
      end

      result =
        if needs_search?(search)
          if search_out_of_bounds?(search[:per_page], search[:page])
            {count: 0, listings: []}
          else
            search_with_sphinx(community_id: community_id, search: search, included_models: included_models)
          end
        else
          fetch_from_db(community_id: community_id, search: search, included_models: included_models)
        end

      {count: result[:count], listings: result[:listings].map { |l| to_hash(l, includes) } }
    end

    private

    def fetch_from_db(community_id:, search:, included_models:)
      where_opts = HashUtils.compact(
        {
          community_id: community_id,
          author_id: search[:author_id]
        })

      query = Listing
        .where(where_opts)
        .includes(included_models)
        .order("listings.sort_date DESC")
        .paginate(per_page: search[:per_page], page: search[:page])

      with_open =
        if search[:include_closed]
          query
        else
          query.currently_open
        end

      {count: with_open.total_entries, listings: with_open}
    end

    def search_with_sphinx(community_id:, search:, included_models:)
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
        # Do a short circuit and return emtpy paginated collection of listings
        {count: 0, listings: []}
      else

        with = HashUtils.compact(
          {
            community_id: community_id,
            category_id: search[:categories], # array of accepted ids
            listing_shape_id: search[:listing_shape_id],
            price_cents: search[:price_cents],
            listing_id: numeric_search_match_listing_ids,
            author_id: search[:author_id]
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
          order: 'sort_date DESC'
        )

        {count: models.total_entries, listings: models}
      end

    end

    def to_hash(l, includes)
      {
        id: l.id,
        title: l.title,
        description: l.description,
        updated_at: l.updated_at,
        created_at: l.created_at,
        category_id: l.category_id,
        comment_count: l.comments_count,
        price: l.price,
        unit_tr_key: l.unit_tr_key,
        unit_type: l.unit_type,
        quantity: l.quantity,
        shape_name_tr_key: l.shape_name_tr_key,
        listing_shape_id: l.listing_shape_id
      }.merge(location_hash(l, includes))
        .merge(author_hash(l, includes))
        .merge(listing_images_hash(l, includes))
    end

    def location_hash(l, includes)
      if includes.include?(:location)
        m_location = Maybe(l.location)
        {
          latitude: m_location.latitude.or_else(nil),
          longitude: m_location.longitude.or_else(nil),
          address: m_location.address.or_else(nil),
        }
      else
        {}
      end
    end

    def author_hash(l, includes)
        if includes.include?(:num_of_reviews) || includes.include?(:author)
          {
            author: {
              id: l.author_id,
              username: l.author.username,
              first_name: l.author.given_name,
              last_name: l.author.family_name,
              organization_name: l.author.organization_name,
              is_organization: l.author.is_organization,
              avatar: {
                thumb: l.author.image(:thumb)
              },
              is_deleted: l.author.deleted?,
            }.merge(num_of_reviews_hash(l, includes))
          }
        else
          {}
        end
    end

    def num_of_reviews_hash(l, includes)
      if includes.include?(:num_of_reviews)
        {num_of_reviews: l.author.received_testimonials.size}
      else
        {}
      end

    end

    def listing_images_hash(l, includes)
        if includes.include?(:listing_images)
          {
            listing_images: Maybe(l.listing_images.first)
              .select { |li| li.image_ready? } # Filter images that are not processed
              .map { |li|
                [{
                  thumb: li.image.url(:thumb),
                  small_3x2: li.image.url(:small_3x2),
                  medium: li.image.url(:medium)
                }]
              }.or_else([])
          }
        else
          {}
        end
    end

    def search_out_of_bounds?(per_page, page)
      pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
      page > pages.ceil
    end

    def needs_db_query?(search)
      search[:author_id].present? || search[:include_closed] == true
    end

    def needs_search?(search)
      [
        :keywords,
        :listing_shape_id,
        :categories, :fields,
        :price_cents
      ].any? { |field| search[field].present? }
    end

    def selection_groups(groups)
      if groups[:search_type] == :and
        groups[:values].flatten
      else
        groups[:values]
      end
    end
  end
end
