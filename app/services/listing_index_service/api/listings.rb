module ListingIndexService::API

  RELATED_RESOURCES = [:listing_images, :author, :num_of_reviews, :location].to_set

  # TODO Maybe conf+injector?
  ENGINE = :sphinx

  ListingIndexResult = ListingIndexService::DataTypes::ListingIndexResult

  class Listings

    def initialize(logger)
      @logger = logger
    end

    def search(community_id:, search:, includes: [])
      unless includes.to_set <= RELATED_RESOURCES
        return Result::Error.new("Unknown included resources: #{(includes.to_set - RELATED_RESOURCES).to_a}")
      end

      search_result = search_engine.search(
        community_id: community_id,
        search: ListingIndexService::DataTypes.create_search_params(search),
        includes: includes
      )

      search_result.maybe().map { |res|
        Result::Success.new(
          ListingIndexResult.call(
          count: res[:count],
          listings: res[:listings].map { |search_res|
            search_res.merge(url: "#{search_res[:id]}-#{search_res[:title].to_url}")}))
      }.or_else {
        log_error(search_result.error_msg)
        Result::Error.new(search_result.error_msg)
      }
    end

    private

    def search_engine
      case ENGINE
      when :sphinx
        ListingIndexService::Search::SphinxAdapter.new
      else
        raise NotImplementedError.new("Adapter for search engine #{ENGINE} not implemented")
      end
    end

    def log_error(err)
      @logger.error(err) unless @logger.nil?
    end
  end

end
