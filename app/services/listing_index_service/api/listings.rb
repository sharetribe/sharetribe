module ListingIndexService::API

  RELATED_RESOURCES = [:listing_images, :author, :num_of_reviews, :location].to_set

  ListingIndexResult = ListingIndexService::DataTypes::ListingIndexResult

  class Listings

    def initialize(logger_target)
      @logger_target = logger_target
    end

    def search(community_id:, search:, includes: [], engine: :sphinx, raise_errors: false)

      unless includes.to_set <= RELATED_RESOURCES
        return Result::Error.new("Unknown included resources: #{(includes.to_set - RELATED_RESOURCES).to_a}")
      end

      search_result = search_engine(engine, raise_errors).search(
        community_id: community_id,
        search: ListingIndexService::DataTypes.create_search_params(search),
        includes: includes
      )

      search_result.maybe().map { |res|
        Result::Success.new(
          process_results(res, engine)
        )
      }.or_else {
        raise search_result.data if raise_errors
        log_error(search_result, community_id)
        search_result
      }
    end

    private

    def process_results(results, engine)
      ListingIndexResult.call(
        count: results[:count],
        listings: results[:listings].map { |search_res|
          search_res.merge(url: "#{search_res[:id]}-#{search_res[:title].to_url}")
        }
      )
    end

    def search_engine(engine, raise_errors)
      case engine
      when :sphinx
        ListingIndexService::Search::SphinxAdapter.new
      when :zappy
        ListingIndexService::Search::ZappyAdapter.new(raise_errors: raise_errors)
      else
        raise NotImplementedError.new("Adapter for search engine #{engine} not implemented")
      end
    end

    def log_error(err_response, community_id)
      logger = SharetribeLogger.new(:listing_index_service,
                                    [:marketplace_id],
                                    @logger_target)
      logger.add_metadata({marketplace_id: community_id})
      logger.error(err_response.error_msg)
    end
  end

end
