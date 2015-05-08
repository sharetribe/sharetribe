module ListingService::Store::Listing
  ListingModel = ::Listing

  UpdateListing = EntityUtils.define_builder(
    [:open, :bool],
    [:listing_shape_id, :fixnum]
  )

  module_function

  def count(community_id:, query:)
    sql_query = where_community(community_id).where(query.except(:open))

    sql_query =
      if query[:open] == true
        sql_query.currently_open
      elsif query[:open] == false
        raise NotImplementedError.new("Count of closed listings is not implemented")
      else
        sql_query
      end

    sql_query.count
  end

  def update_all(community_id: nil, query:, opts:)
    if community_id != nil
      raise NotImplementedError.new("Community id is ignored")
    end

    ListingModel.where(query).update_all(opts)
  end

  # private

  def where_community(community_id)
    ListingModel
      .includes(:communities)
      .where(communities: {id: community_id})
  end
end
