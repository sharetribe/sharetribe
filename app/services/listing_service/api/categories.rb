module ListingService::API
  CategoryStore = ListingService::Store::Category

  class Categories
    def get_all(community_id:)
      Result::Success.new(
        CategoryStore.get_all(community_id: community_id)
      )
    end

    def create(community_id:, opts:)
      Result::Success.new(
        CategoryStore.create(community_id: community_id, opts: opts)
      )
    end
  end
end
