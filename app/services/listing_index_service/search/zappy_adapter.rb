module ListingIndexService::Search

  class ZappyAdapter < SearchEngineAdapter

    def initialize
      @conn = Faraday.new(url: "http://127.0.0.1:8080") do |c|
         c.request  :url_encoded             # form-encode POST params
         c.response :logger                  # log requests to STDOUT
         c.response :json, :content_type => /\bjson$/
         c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
 
    def search(community_id:, search:, includes: nil)
 
      begin
        res = @conn.get do |req|
          req.url '/api/v1/marketplace/1/listings', {keywords: search[:keywords]}
          req.headers['Authorization'] = 'apikey key=asdf1234'
        end.body
        Result::Success.new(parse_response(res["result"], includes))
      rescue StandardError => e
        Result::Error.new(e)
      end
    end

    private

    def listings_from_ids(ids, includes)
      # use pluck for much faster query after updating to Rails >4.1.6
      # http://collectiveidea.com/blog/archives/2015/03/05/optimizing-rails-for-memory-usage-part-3-pluck-and-database-laziness/
      # https://github.com/rails/rails/issues/17049

      Listing
        .where(id: res) # use find_each for more efficient batch processing after updating to Rails 4.1
        .order("field(listings.id, #{res.join ','})")
        .map {
          |l| ListingIndexService::Search::Commons.listing_hash(l, includes)
        }
    end

    def parse_response(res, includes)
      listings = res.count > 0 ? listings_from_ids(res) : []
      {count: res.count,
       listings: listings}
    end
  end
end
