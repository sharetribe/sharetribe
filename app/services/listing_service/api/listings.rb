module ListingService::API
  ListingStore = ListingService::Store::Listing

  QueryParams = EntityUtils.define_builder(
    [:listing_shape_id, :fixnum],
    [:open, :bool]
  )

  SelectionGroups = EntityUtils.define_builder(
    [:values, :array, :mandatory],
    [:search_type, one_of: [:and, :or]],
  )

  SearchParams = EntityUtils.define_builder(
    [:page, :to_integer, default: 1, gte: 1],
    [:per_page, :to_integer, :mandatory, gte: 1],
    [:keywords, :string, :optional],
    [:category_id, :fixnum, :optional],
    [:listing_shape_id, :fixnum, :optional],
    [:price_cents, :range, :optional],
    [:checkboxes, entity: SelectionGroups],
    [:dropdowns, entity: SelectionGroups],
  )

  AvatarImage = EntityUtils.define_builder(
    [:thumb, :string],
  )

  ListingImage = EntityUtils.define_builder(
    [:thumb, :string],
    [:small_3x2, :string],
    [:medium, :string],
  )

  Author = EntityUtils.define_builder(
    [:id, :string, :mandatory],
    [:username, :string, :mandatory],
    [:first_name, :string, :mandatory],
    [:last_name, :string, :mandatory],
    [:avatar, entity: AvatarImage],
    [:is_deleted, :bool, default: false],
    [:num_of_reviews, :fixnum, default: 0]
  )

  Listing = EntityUtils.define_builder(
    [:id, :fixnum, :mandatory],
    [:title, :string, :mandatory],
    [:description, :string],
    [:category_id, :fixnum, :mandatory],
    [:author, :mandatory, entity: Author],
    [:listing_images, collection: ListingImage],
    [:updated_at, :time, :mandatory],
    [:created_at, :time, :mandatory],
    [:latitude],
    [:longitude],
    [:address, :string],
    [:comment_count, :fixnum, :optional],
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
      s = SearchParams.call(search)
      categories = search_category_ids(community_id: community_id, category_id: s[:category_id])

      Result::Success.new(
        search_engine.search(
          community_id: community_id,
          search: s.merge(
            categories: categories
          )
        ).map { |search_res|
          Listing.call(search_res)
        }
      )
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

    # Takes category id, and returns a list of ids of current and child categories
    def search_category_ids(community_id:, category_id:)
      Maybe(category_id).map { |cat_id|
        ListingService::API::Api.categories.get(community_id: community_id, category_id: cat_id).data
      }.map { |category_tree|
        HashUtils.deep_pluck([category_tree], :children, :id)
      }.or_else(nil)
    end

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
