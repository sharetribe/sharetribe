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

    scope = Listing
    scope = scope.use_homepage_index if !search[:include_closed] && !search[:author_id]
    scope = scope.currently_open unless search[:include_closed]
    listings = scope.where(where_opts)
                 .includes(included_models)
                 .order("listings.sort_date DESC")
                 .paginate(per_page: search[:per_page], page: search[:page])

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
      :listing_shape_ids,
      :categories,
      :fields,
      :price_cents
    ].any? { |field| search[field].present? }
  end

end
