module ListingService::Store::Listing
  ListingModel = ::Listing

  module_function

  def count(community_id:, query:)
    where_models(community_id, query).count
  end

  def update_all(community_id: nil, query:, opts:)
    opts[:updated_at] = opts[:updated_at] || Time.now
    where_models(community_id, query).update_all(SQLUtils.hash_to_query(listings: opts))
  end

  # private

  # Construct ActiveRecord query based on community_id and the
  # query params
  def where_models(community_id, query)
    ar_query = ListingModel
      .where(community_id: community_id)

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
