module ListingService::API
  ShapeStore = ListingService::Store::Shape

  class Shapes

    # TODO Get rid of transaction_type_id
    # Current implementation can seach listing shapes by transaction_type_id or listing_shape_id.
    # This will change in the future.
    def get(community_id:, listing_shape_id: nil, transaction_type_id: nil)
      find_opts = {
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        transaction_type_id: transaction_type_id
      }

      Maybe(ShapeStore.get(find_opts)).map { |shape|
        Result::Success.new(shape)
      }.or_else {
        Result::Error.new("Can not find listing shape for #{find_opts}")
      }
    end

    # TODO Move transaction_type creation inside the API
    # That way we can get rid of the transaction_type_id
    def create(community_id:, opts:)
      Result::Success.new(ShapeStore.create(
        community_id: community_id,
        opts: opts
      ))
    end

    def update(community_id:, listing_shape_id: nil, transaction_type_id: nil, opts:)
      find_opts = {
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        transaction_type_id: transaction_type_id
      }

      Maybe(ShapeStore.update(find_opts.merge(opts: opts))).map { |shape|
        Result::Success.new(shape)
      }.or_else {
        Result::Error.new("Can not find listing shape for #{find_opts}")
      }
    end

  end
end
