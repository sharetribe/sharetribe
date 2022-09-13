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
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::INFO # log only on INFO level so that secrets are not logged
      @conn = Faraday.new(url: SEARCH_URL) do |c|
         c.request  :url_encoded             # form-encode POST params
         c.response :logger, logger          # log requests to STDOUT
         c.response :json, :content_type => /\bjson$/
         c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
         c.use Faraday::Response::RaiseError if raise_errors
      end
    end

    def search(community_id:, search:, includes: nil)
      included_models = includes.map { |m| INCLUDE_MAP[m] }

      if DatabaseSearchHelper.needs_db_query?(search) && DatabaseSearchHelper.needs_search?(search)
        return Result::Error.new(ArgumentError.new("Both DB query and search engine would be needed to fulfill the search"))
      end

      if DatabaseSearchHelper.needs_search?(search)
        begin
          res = @conn.get do |req|
            req.url("/api/v1/marketplace/#{community_id}/listings", format_params(search))
            req.headers['Authorization'] = "apikey key=#{API_KEY}"
          end
          Result::Success.new(parse_response(res.body, includes))
        rescue StandardError => e
          Result::Error.new(e)
        end
      else
        DatabaseSearchHelper.fetch_from_db(community_id: community_id,
                                           search: search,
                                           included_models: included_models,
                                           includes: includes)
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
            :'filter[distance_max]' => original[:distance_max]
          }
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

    def listings_from_ids(id_obs, includes)
      # TODO: use pluck instead of instantiating the ActiveRecord objects completely, for better performance
      # http://collectiveidea.com/blog/archives/2015/03/05/optimizing-rails-for-memory-usage-part-3-pluck-and-database-laziness/

      l_ids = id_obs.map { |r| r['id'] }
      data_by_id =  Hash[id_obs.map { |m| [m['id'].to_i, m] }]

      Maybe(l_ids).map { |ids|
        Listing
          .where(id: ids)
          .order("field(listings.id, #{ids.join ','})")
          .map { |l|
            distance_hash = parse_distance(data_by_id[l.id])
            ListingIndexService::Search::Converters.listing_hash(l, includes, distance_hash)
          }
      }.or_else([])
    end

    def parse_response(res, includes)
      listings = listings_from_ids(res["data"], includes)

      {count: res["meta"]["total"],
       listings: listings}
    end

    def parse_distance(data)
      Maybe(data['meta'])
        .map{ |m|
          distance = m['distance']
          distance_unit = m['distance-unit']
          if(distance.present? && distance_unit.present?)
            { distance: distance, distance_unit: distance_unit }
          else
            {}
          end
        }.or_else({})
    end
  end
end
