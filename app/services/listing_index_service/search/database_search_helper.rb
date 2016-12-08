module ListingIndexService::Search::DatabaseSearchHelper

  module_function

  def success_result(count, listings, includes)
    Result::Success.new(
      {count: count, listings: listings.map { |l| ListingIndexService::Search::Converters.listing_hash(l, includes) }})
  end

  def fetch_from_db(community_id:, search:, included_models:, includes:)
    where_opts = HashUtils.compact(
      {
        community_id: community_id,
        author_id: search[:author_id],
        deleted: 0,
        listing_shape_id: Maybe(search[:listing_shape_ids]).or_else(nil)
      })

    query = Listing
            .where(where_opts)
            .includes(included_models)
            .order("listings.sort_date DESC")
            .paginate(per_page: search[:per_page], page: search[:page])

    listings =
      if search[:include_closed]
        query
      else
        query.currently_open
      end

    success_result(listings.total_entries, listings, includes)
  end

  # TODO: This should probably be rethought when the Indexer and the
  # new Search API is finished and in use
  def needs_db_query?(search)
    search[:author_id].present? || search[:include_closed] == true
  end

  def needs_search?(search)
    [
      :keywords,
      :latitude,
      :longitude,
      :distance_max,
      :sort,
      :listing_shape_id,
      :categories,
      :fields,
      :price_cents
    ].any? { |field| search[field].present? }
  end

end
