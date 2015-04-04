module ListingService::API
  CategoryStore = ListingService::Store::Category

  class Categories
    def get(community_id:)
      Result::Success.new(
        CategoryStore.get_all(community_id: community_id)
      )
    end
  end
end
