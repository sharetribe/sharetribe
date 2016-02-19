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
      search_params = format_params(search)

      if DatabaseSearchHelper.needs_db_query?(search) && DatabaseSearchHelper.needs_search?(search)
        return Result::Error.new(ArgumentError.new("Both DB query and search engine would be needed to fulfill the search"))
      end

      if DatabaseSearchHelper.needs_search?(search)
        # TODO: is out-of-bounds check necessary here?
        begin
          res = @conn.get do |req|
            req.url("/api/v1/marketplace/#{community_id}/listings", search_params)
            req.headers['Authorization'] = "apikey key=#{API_KEY}"
          end
          distance_unit_system = MarketplaceService::API::Api.configurations.get(community_id: community_id).data[:distance_unit]
          Result::Success.new(parse_response(res.body, includes, (distance_unit_system == :metric) ? :km : :miles))
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
      search_params =
        if(original[:latitude].present? && original[:longitude].present?)
          { :'search[lat]' => original[:latitude],
            :'search[lng]' => original[:longitude]
          }
        else
          { :'search[keywords]' => original[:keywords]}
        end

      {
       :'page[number]' => original[:page],
       :'page[size]' => original[:per_page],
       :'filter[price_min]' => Maybe(original[:price_cents]).min,
       :'filter[price_max]' => Maybe(original[:price_cents]).max,
       :'filter[omit_closed]' => !original[:include_closed],
       :'filter[listing_shape_ids]' => Maybe(original[:listing_shape_ids]).join(",").or_else(nil),
       :'filter[category_ids]' => Maybe(original[:categories]).join(",").or_else(nil),
       :'search[locale]' => original[:locale]
      }.merge(search_params).compact
    end

    def listings_from_ids(id_obs, includes, distance_unit)
      # TODO: use pluck instead of instantiating the ActiveRecord objects completely, for better performance
      # http://collectiveidea.com/blog/archives/2015/03/05/optimizing-rails-for-memory-usage-part-3-pluck-and-database-laziness/

      l_ids = id_obs.map { |r| r['id'] }
      data_by_id =  Hash[id_obs.map { |m| [m['id'].to_i, m] }]

      Maybe(l_ids).map { |ids|
        Listing
          .where(id: ids)
          .order("field(listings.id, #{ids.join ','})")
          .map { |l|
            d = data_by_id[l.id]
            meta  = Maybe(d['meta']).or_else({})
            distance_hash = convert_distance(meta, distance_unit)

            ListingIndexService::Search::Converters.listing_hash(l, includes, distance_hash)
          }
      }.or_else([])
    end

    def parse_response(res, includes, distance_unit)
      listings = listings_from_ids(res["data"], includes, distance_unit)

      {count: res["meta"]["total"],
       listings: listings}
    end

    def convert_distance(meta_obj, distance_unit)
      Maybe(meta_obj['distance'])
        .map{ |d|
          distance = (distance_unit == :km) ? d : (d / 1.609344)
          { distance: distance, distance_unit: distance_unit }
        }.or_else({})
    end
  end
end
