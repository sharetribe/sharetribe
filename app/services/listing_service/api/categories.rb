module ListingService::API
  CategoryStore = ListingService::Store::Category

  class Categories
    def get_all(community_id:)
      Result::Success.new(
        CategoryStore.get_all(community_id: community_id)
      )
    end

    def get(community_id:, category_id:)
      res = HashUtils.deep_find(CategoryStore.get_all(community_id: community_id), :children) { |cat|
        cat[:id] == category_id
      }

      if res.nil?
        Result::Error.new("Can not find category for community_id: #{community_id}, category_id: #{category_id}")
      else
        Result::Success.new(res)
      end
    end

    def create(community_id:, opts:)
      Result::Success.new(
        CategoryStore.create(community_id: community_id, opts: opts)
      )
    end
  end
end
