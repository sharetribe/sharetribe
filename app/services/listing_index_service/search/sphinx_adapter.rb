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

    def search(community_id:, search:, include:)
      included_models = include.map { |m| INCLUDE_MAP[m] }

      result =
        if needs_search?(search)
          if search_out_of_bounds?(search[:per_page], search[:page])
            []
          else
            search_with_sphinx(community_id: community_id, search: search, included_models: included_models)
          end
        else
          fetch_from_db(community_id: community_id, search: search, included_models: included_models)
        end

      result.map { |l| to_hash(l, include) }
    end

    private

    def fetch_from_db(community_id:, search:, included_models:)
      Listing
        .where(community_id: community_id)
        .includes(included_models)
        .currently_open("open")
        .order("listings.sort_date DESC")
        .paginate(per_page: search[:per_page], page: search[:page])
    end

    def search_with_sphinx(community_id:, search:, included_models:)
      perform_numeric_search = search[:numbers].present?

      numeric_search_match_listing_ids =
        if search[:numbers].present?
          numeric_search_params = search[:numbers].map { |n|
            { custom_field_id: n[:id], numeric_value: n[:range] }
          }
          NumericFieldValue.search_many(numeric_search_params).collect(&:listing_id)
        else
          []
        end

      if perform_numeric_search && numeric_search_match_listing_ids.empty?
        # No matches found with the numeric search
        # Do a short circuit and return emtpy paginated collection of listings
        []
      else

        with = HashUtils.compact(
          {
            community_id: community_id,
            category_id: search[:categories], # array of accepted ids
            listing_shape_id: search[:listing_shape_id],
            price_cents: search[:price_cents],
            listing_id: numeric_search_match_listing_ids,
          })

        with_all = {
          custom_dropdown_field_options: selection_groups(search[:dropdowns]),
          custom_checkbox_field_options: selection_groups(search[:checkboxes])
        }

        Listing.search(
          Riddle::Query.escape(search[:keywords] || ""),
          include: included_models,
          page: search[:page],
          per_page: search[:per_page],
          star: true,
          with: with,
          with_all: with_all,
          order: 'sort_date DESC'
        )
      end

    end

    def to_hash(l, include)
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
      }.merge(location_hash(l, include))
        .merge(author_hash(l, include))
        .merge(listing_images_hash(l, include))
    end

    def location_hash(l, include)
      if include.include?(:location)
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

    def author_hash(l, include)
        if include.include?(:num_of_reviews) || include.include?(:author)
          {
            author: {
              id: l.author_id,
              username: l.author.username,
              first_name: l.author.given_name,
              last_name: l.author.family_name,
              avatar: {
                thumb: l.author.image(:thumb)
              },
              is_deleted: l.author.deleted?,
            }.merge(num_of_reviews_hash(l, include))
          }
        else
          {}
        end
    end

    def num_of_reviews_hash(l, include)
      if include.include?(:num_of_reviews)
        {num_of_reviews: l.author.received_testimonials.size}
      else
        {}
      end

    end

    def listing_images_hash(l, include)
        if include.include?(:listing_images)
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

    def needs_search?(search)
      search[:keywords].present? ||
        search[:listing_shape_id].present? ||
        search[:categories].present? ||
        (search[:checkboxes] && search[:checkboxes][:values].present?) ||
        (search[:dropdowns] && search[:dropdowns][:values].present?) ||
        search[:numbers].present? ||
        search[:price_cents].present?
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
