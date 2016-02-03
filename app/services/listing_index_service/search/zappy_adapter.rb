module ListingIndexService::Search

  class ZappyAdapter < SearchEngineAdapter

    INCLUDE_MAP = {
      listing_images: :listing_images,
      author: :author,
      num_of_reviews: {author: :received_testimonials},
      location: :location
    }

    API_KEY = APP_CONFIG.external_search_apikey
    SEARCH_URL = APP_CONFIG.external_search_url

    def initialize(raise_errors:)
      @conn = Faraday.new(url: SEARCH_URL) do |c|
         c.request  :url_encoded             # form-encode POST params
         c.response :logger                  # log requests to STDOUT
         c.response :json, :content_type => /\bjson$/
         c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
         c.use Faraday::Response::RaiseError if raise_errors
      end
    end

    def search(community_id:, search:, includes: nil)
      included_models = includes.map { |m| INCLUDE_MAP[m] }
      search_params = format_params(search)

      if needs_db_query?(search) && needs_search?(search)
        return Result::Error.new(ArgumentError.new("Both DB query and search engine would be needed to fulfill the search"))
      end

      if needs_search?(search)
        # TODO: is out-of-bounds check necessary here?
        begin
          res = @conn.get do |req|
            req.url("/api/v1/marketplace/#{community_id}/listings", search_params)
            req.headers['Authorization'] = "apikey key=#{API_KEY}"
          end
          Result::Success.new(parse_response(res.body, includes))
        rescue StandardError => e
          Result::Error.new(e)
        end
      else
        fetch_from_db(community_id: community_id,
                      search: search,
                      included_models: included_models,
                      includes: includes)
      end
    end

    private

    def format_params(original)
      {
       :'search-keywords' => original[:keywords],
       :'page[number]' => original[:page],
       :'page[size]' => original[:per_page]
      }.compact
    end

    def listings_from_ids(id_obs, includes)
      # use pluck for much faster query after updating to Rails >4.1.6
      # http://collectiveidea.com/blog/archives/2015/03/05/optimizing-rails-for-memory-usage-part-3-pluck-and-database-laziness/
      # https://github.com/rails/rails/issues/17049

      ids = id_obs.map { |r| r['id'] }

      Listing
        .where(id: ids) # use find_each for more efficient batch processing after updating to Rails 4.1
        .order("field(listings.id, #{ids.join ','})")
        .map {
          |l| ListingIndexService::Search::Commons.listing_hash(l, includes)
        }
    end

    def parse_response(res, includes)
      listings = res["meta"]["total"] > 0 ? listings_from_ids(res["data"], includes) : []
      {count: res["meta"]["total"],
       listings: listings}
    end
  end
end
