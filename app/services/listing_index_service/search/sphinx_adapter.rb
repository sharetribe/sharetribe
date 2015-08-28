module ListingIndexService::Search

  class SphinxAdapter < SearchEngineAdapter

    # http://pat.github.io/thinking-sphinx/advanced_config.html
    SPHINX_MAX_MATCHES = 1000

    INCLUDED_MODELS = [:listing_images, :category, {author: :received_testimonials}, :location]

    def search(community_id:, search:)
      result =
        if search_out_of_bounds?(search[:per_page], search[:page])
          []
        elsif !search_with_sphinx?(search)
          Listing
            .where(community_id: community_id)
            .includes(INCLUDED_MODELS)
            .currently_open("open")
            .order("listings.sort_date DESC")
            .paginate(per_page: search[:per_page], page: search[:page])
        else
          with = HashUtils.compact(
            {
              community_id: community_id,
              category_id: search[:categories], # array of accepted ids
              listing_shape_id: search[:listing_shape_id],
              price_cents: search[:price_cents],
              listing_id: search[:listing_ids],
            })

          with_all = {
            custom_dropdown_field_options: selection_groups(search[:dropdowns]),
            custom_checkbox_field_options: selection_groups(search[:checkboxes])
          }

          Listing.search(
            Riddle::Query.escape(search[:keywords] || ""),
            include: INCLUDED_MODELS,
            page: search[:page],
            per_page: search[:per_page],
            star: true,
            with: with,
            with_all: with_all,
            order: 'sort_date DESC'
          )
        end

      result.map { |l| to_hash(l) }
    end

    private

    def to_hash(l)
      {
        id: l.id,
        title: l.title,
        description: l.description,
        updated_at: l.updated_at,
        created_at: l.created_at,
        category_id: l.category_id,
        latitude: Maybe(l.location).latitude.or_else(nil),
        longitude: Maybe(l.location).longitude.or_else(nil),
        address: Maybe(l.location).address.or_else(nil),
        comment_count: l.comments_count,
        author: {
          id: l.author_id,
          username: l.author.username,
          first_name: l.author.given_name,
          last_name: l.author.family_name,
          avatar: {
            thumb: l.author.image(:thumb)
          },
          is_deleted: l.author.deleted?,
          num_of_reviews: l.author.received_testimonials.size
        },
        listing_images: l.listing_images
          .select { |li| li.image_ready? } # Filter images that are not processed
          .map { |li|
            {
              thumb: li.image.url(:thumb),
              small_3x2: li.image.url(:small_3x2),
              medium: li.image.url(:medium)
            }
        },
        price: l.price,
        unit_tr_key: l.unit_tr_key,
        unit_type: l.unit_type,
        quantity: l.quantity,
        shape_name_tr_key: l.shape_name_tr_key,
        listing_shape_id: l.listing_shape_id,
        icon_name: l.icon_name
      }
    end

    def search_out_of_bounds?(per_page, page)
      pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
      page > pages.ceil
    end

    def search_with_sphinx?(search)
      search[:keywords].present? ||
        search[:listing_shape_id].present? ||
        search[:categories].present? ||
        search[:checkboxes][:values].present? ||
        search[:dropdowns][:values].present? ||
        search[:listing_ids].present? ||
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
