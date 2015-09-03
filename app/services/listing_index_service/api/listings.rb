module ListingIndexService::API

  RELATED_RESOURCES = [:listing_images, :author, :num_of_reviews, :location].to_set

  # TODO Maybe conf+injector?
  ENGINE = :sphinx

  SearchParams = ListingIndexService::DataTypes::SearchParams
  Listing = ListingIndexService::DataTypes::Listing

  class Listings

    def search(community_id:, search:, includes: [])

      unless includes.to_set <= RELATED_RESOURCES
        return Result::Error.new("Unknown included resources: #{(includes.to_set - RELATED_RESOURCES).to_a}")
      end

      s = ListingIndexService::DataTypes.create_search_params(search)

      Result::Success.new(
        search_engine.search(
          community_id: community_id,
          search: s,
          includes: includes
        ).map { |search_res|
          Listing.call(search_res.merge(url: "#{search_res[:id]}-#{search_res[:title].to_url}"))
        }
      )
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
  end

end
