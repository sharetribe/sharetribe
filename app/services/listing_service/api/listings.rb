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
  end
end
