module ListingIndexService::Search

  class SearchEngineAdapter

    def search(community_id:, search:)
      raise InterfaceMethodNotImplementedError.new
    end
  end
end
