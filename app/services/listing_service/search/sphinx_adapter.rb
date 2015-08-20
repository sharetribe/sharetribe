module ListingService::Search

  class SphinxAdapter < SearchEngineAdapter

    # http://pat.github.io/thinking-sphinx/advanced_config.html
    SPHINX_MAX_MATCHES = 1000

    INCLUDED_MODELS = [:listing_images, :author, :category]

    def search(community_id:, search:)
      if search_out_of_bounds?(search[:per_page], search[:page])
        []
      else
        with = {
          community_id: community_id
        }

        with_all = {

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
        ).map { |l|
          {
            id: l.id,
            title: l.title,
            description: l.description,
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
            listing_images: l.listing_images.map { |li| { thumb: li.image.url(:thumb), small_3x2: li.image.url(:small_3x2)} },
            price: l.price,
            unit_tr_key: l.unit_tr_key,
            unit_type: l.unit_type,
            quantity: l.quantity,
            shape_name_tr_key: l.shape_name_tr_key,
            listing_shape_id: l.listing_shape_id,
            icon_name: l.icon_name
          }
        }
      end
    end

    private

    def search_out_of_bounds?(per_page, page)
      pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
      page > pages.ceil
    end
  end
end
