module ListingService::API
  ListingStore = ListingService::Store::Listing

  QueryParams = EntityUtils.define_builder(
    [:listing_shape_id, :fixnum],
    [:open, :bool]
  )

  class Listings

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
        Result::Error.new("Cannot find listings #{find_opts}")
      }
    end

  end
end
