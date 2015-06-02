module ListingService::Store::Listing
  ListingModel = ::Listing

  module_function

  def count(community_id:, query:)
    where_models(community_id, query).count
  end

  def update_all(community_id: nil, query:, opts:)
    where_models(community_id, query).update_all(opts)
  end

  # private

  # Construct ActiveRecord query based on community_id and the
  # query params
  def where_models(community_id, query)
    ar_query = ListingModel
      .joins(:communities)
      .where(communities: {id: community_id})

    ar_query =
      if query[:open] == true
        ar_query.currently_open
      elsif query[:open] == false
        raise NotImplementedError.new("Count of closed listings is not implemented")
      else
        ar_query
      end

    ar_query.where(query.except(:open))
  end
end
