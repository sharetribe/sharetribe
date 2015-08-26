module ListingService::API
  ListingStore = ListingService::Store::Listing

  QueryParams = EntityUtils.define_builder(
    [:listing_shape_id, :fixnum],
    [:open, :bool]
  )

  SearchParams = EntityUtils.define_builder(
    [:page, :fixnum, gte: 1, default: 1],
    [:per_page, :fixnum, gte: 1, default: 100],
    [:keywords, :string, :optional],
    [:category_id, :fixnum, :optional],
    [:listing_shape_id, :fixnum, :optional],
    # TODO [:price_cents]
  )

  ListingImage = EntityUtils.define_builder(
    [:thumb, :string],
    [:small_3x2, :string]
  )

  Author = EntityUtils.define_builder(
    [:id, :string, :mandatory],
    [:username, :string, :mandatory],
    [:first_name, :string, :mandatory],
    [:last_name, :string, :mandatory],
    [:avatar, entity: ListingImage],
    [:is_deleted, :bool, default: false],
    [:num_of_reviews, :fixnum, default: 0]
  )

  Listing = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:title, :string, :mandatory],
    [:description, :string],
    [:author, :mandatory, entity: Author],
    [:listing_images, collection: ListingImage],
    [:price, :money],
    [:unit_tr_key, :string], # TODO is this mandatory?
    [:unit_type], # TODO Symbol or string?
    [:quantity, :string], # This is outdated
    [:shape_name_tr_key, :string], # TODO is this mandatory?
    [:listing_shape_id, :fixnum, :optional], # This can be nil, if the listing shape was deleted
    [:icon_name, :string], # TODO What's this?
  )

  # TODO Maybe conf+injector?
  ENGINE = :sphinx

  class Listings

    def search(community_id:, search: {})
      SearchParams.validate(search).and_then { |s|
        categories = Maybe(s)[:category_id].map { |cat_id|
          ListingService::API::Api.categories.get(community_id: community_id, category_id: cat_id).data
        }.map { |category_tree|
          HashUtils.deep_pluck([category_tree], :children, :id)
        }.or_else(nil)

        Result::Success.new(
          search_engine.search(
          community_id: community_id,
          search: s.merge(
            categories: categories
          )
        ).map { |search_res|
          Listing.call(search_res)
        })
      }.on_error { |e|
        Result::Error.new(e)
      }
    end

    def count(community_id:, query: {})
      q = HashUtils.compact(QueryParams.call(query))
      Result::Success.new(
        ListingStore.count(community_id: community_id, query: q))
    end

    def update_all(community_id:, query: {}, opts: {})
      find_opts = {
        community_id: community_id,
        query: query
      }

      Maybe(ListingStore.update_all(find_opts.merge(opts: opts))).map {
        Result::Success.new()
      }.or_else {
        Result::Error.new("Can not find listings #{find_opts}")
      }
    end

    private

    def search_engine
      case ENGINE
      when :sphinx
        ListingService::Search::SphinxAdapter.new
      else
        raise NotImplementedError.new("Adapter for search engine #{ENGINE} not implemented")
      end
    end
  end
end
