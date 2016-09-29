module ListingIndexService::Search

  class DiscoveryAdapter < SearchEngineAdapter
    API_KEY = APP_CONFIG.external_search_apikey
    SEARCH_URL = APP_CONFIG.external_search_url

    def initialize(raise_errors:)
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::INFO # log only on INFO level so that secrets are not logged
      @conn = Faraday.new(url: SEARCH_URL) do |c|
         c.request  :url_encoded             # form-encode POST params
         c.response :logger, logger          # log requests to STDOUT
         c.response :encoding
         c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
         c.use Faraday::Response::RaiseError if raise_errors
      end
    end

    def search(community_id:, search:, includes: nil)
      path_base = "/discovery/listings/query"
      begin
        res = @conn.get do |req|
          req.url(path_base, format_params(search.merge({marketplace_id: community_id})))
          req.headers['Authorization'] = "apikey key=#{API_KEY}"
          req.headers['Accept'] = "application/transit+json"
        end
        result = res.body
        Result::Success.new(result)
      rescue StandardError => e
        Result::Error.new(e)
      end
    end

    private

    def format_params(original)
      location_params =
        if(original[:latitude].present? && original[:longitude].present?)
          { :'search[lat]' => original[:latitude],
            :'search[lng]' => original[:longitude],
            :'search[distance_unit]' => original[:distance_unit],
            :'search[scale]' => original[:scale],
            :'search[offset]' => original[:offset],
            :'filter[distance_max]' => original[:distance_max] }
        else
          {}
        end

      custom_fields = Maybe(original[:fields]).map { |fields|
        fields.select { |f| [:numeric_range, :selection_group].include?(f[:type]) }
        fields.map { |f|
          if f[:type]  == :numeric_range
            [:"custom[#{f[:id]}]", "double:#{f[:value].first}:#{f[:value].last}"]
          else
            [:"custom[#{f[:id]}]", "opt:#{f[:operator]}:#{f[:value].join(",")}"]
          end
        }.to_h
      }.or_else({})

      {
       :'search[keywords]' => original[:keywords],
       :'page[number]' => original[:page],
       :'page[size]' => original[:per_page],
       :'filter[price_min]' => Maybe(original[:price_cents]).map{ |p| p.min }.or_else(nil),
       :'filter[price_max]' => Maybe(original[:price_cents]).map{ |p| p.max }.or_else(nil),
       :'filter[omit_closed]' => !original[:include_closed],
       :'filter[listing_shape_ids]' => Maybe(original[:listing_shape_ids]).join(",").or_else(nil),
       :'filter[category_ids]' => Maybe(original[:categories]).join(",").or_else(nil),
       :'search[locale]' => original[:locale],
       :sort => original[:sort]
      }.merge(location_params).merge(custom_fields).compact
    end
  end
end