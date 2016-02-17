module ListingService::API
  ShapeStore = ListingService::Store::Shape

  class Shapes

    def get(community_id:, listing_shape_id: nil, name: nil, include_categories: false)
      find_opts = {
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        name: name,
        include_categories: include_categories
      }

      validate_find_opts(find_opts, unique_result_required: false).and_then { |f_opts|
        if f_opts[:listing_shape_id] || f_opts[:name]
          Maybe(ShapeStore.get(f_opts)).map { |shape|
            Result::Success.new(shape)
          }.or_else {
            Result::Error.new("Cannot find listing shape for #{f_opts}")
          }
        else
          Result::Success.new(ShapeStore.get_all(community_id: community_id, include_categories: include_categories))
        end
      }
    end

    def create(community_id:, opts:)
      Result::Success.new(ShapeStore.create(
        community_id: community_id,
        opts: opts
      ))
    end

    def update(community_id:, listing_shape_id: nil, name: nil, opts:)
      find_opts = {
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        name: name
      }

      validate_find_opts(find_opts, unique_result_required: true).and_then { |f_opts|
        Maybe(ShapeStore.update(f_opts.merge(opts: opts))).map { |shape|
          Result::Success.new(shape)
        }.or_else {
          Result::Error.new("Cannot find listing shape for #{f_opts}")
        }
      }
    end

    def delete(community_id:, listing_shape_id: nil, name: nil)
      find_opts = {
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        name: name
      }

      validate_find_opts(find_opts, unique_result_required: true).and_then { |f_opts|
        Maybe(ShapeStore.delete(f_opts)).map { |shape|
          Result::Success.new(shape)
        }.or_else {
          Result::Error.new("Cannot find listing shape for #{f_opts}")
        }
      }
    end

    private

    def validate_find_opts(opts, unique_result_required:)
      if opts[:listing_shape_id].present? && opts[:name].present?
        return Result::Error.new("Cannot have both listing shape id (#{opts[:listing_shape_id]}) and name (#{opts[:name]}) present.")
      elsif unique_result_required && opts[:listing_shape_id].nil? && opts[:name].nil?
        return Result::Error.new("Must have either id or name present.")
      else
        Result::Success.new(opts)
      end
    end

  end
end
