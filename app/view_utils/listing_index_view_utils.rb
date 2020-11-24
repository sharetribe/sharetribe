module ListingIndexViewUtils

  ListingItem = Struct.new(
    :id,
    :url,
    :title,
    :category_id,
    :latitude,
    :longitude,
    :distance,
    :distance_unit,
    :author,
    :description,
    :listing_images,
    :price,
    :unit_tr_key,
    :unit_type,
    :quantity,
    :shape_name_tr_key,
    :listing_shape_id,
    :icon_name)

  Author = Struct.new(
    :id,
    :username,
    :first_name,
    :last_name,
    :display_name,
    :avatar,
    :is_deleted,
    :num_of_reviews)

  ListingImage = Struct.new(
    :thumb,
    :small_3x2,
    :medium)

  module_function

  def to_struct(result:, includes:, per_page:, page:)
    listings = result[:listings].map { |l|
      author =
        if includes.include?(:author)
          Author.new(
            l[:author][:id],
            l[:author][:username],
            l[:author][:first_name],
            l[:author][:last_name],
            l[:author][:display_name],
            ListingImage.new(
              l[:author][:avatar][:thumb]
            ),
            l[:author][:is_deleted],
            l[:author][:num_of_reviews]
          )
        end

      listing_images =
        if includes.include?(:listing_images)
          l[:listing_images].map { |li|
            ListingImage.new(li[:thumb], li[:small_3x2], li[:medium])
          }
        else
          []
        end

      ListingItem.new(
        l[:id],
        l[:url],
        l[:title],
        l[:category_id],
        l[:latitude],
        l[:longitude],
        l[:distance],
        l[:distance_unit],
        author,
        l[:description],
        listing_images,
        l[:price],
        l[:unit_tr_key],
        l[:unit_type],
        l[:quantity],
        l[:shape_name_tr_key],
        l[:listing_shape_id],
        l[:icon_name]
      )
    }

    paginated = WillPaginate::Collection.create(page, per_page, result[:count]) do |pager|
      pager.replace(listings)
    end
  end
end
