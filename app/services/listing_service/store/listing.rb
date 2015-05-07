module ListingService::Store::Listing
  ListingModel = ::Listing

  module_function

  def count(community_id:, query:)
    sql_query = ListingModel
                .includes(:communities)
                .where(communities: {id: community_id})
                .where(query.except(:open))

    sql_query =
      if query[:open]
        sql_query.currently_open
      else
        sql_query
      end

    sql_query.count
  end
end
