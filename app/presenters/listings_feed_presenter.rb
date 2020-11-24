class ListingsFeedPresenter
  attr_accessor :direction_map, :listings, :title

  def initialize(community, shapes, processes, params)
    @direction_map = build_direction_map(shapes, processes, params)
    @listings = search_listings(community, params).data[:listings]
    @title = build_title(community, params)
  end

  def build_direction_map(shapes, processes, params)
    direction_map = ListingShapeHelper.shape_direction_map(shapes, processes)

    if params[:share_type].present?
      direction = params[:share_type]
      params[:listing_shapes] = shapes.select{|shape| direction_map[shape[:id]] == direction }.map{|shape| shape[:id]}
    end
    direction_map
  end

  def search_listings(community, params)
    page =  params[:page] || 1
    per_page = params[:per_page] || 50

    raise_errors = Rails.env.development?

    if community.private
      Result::Success.new({count: 0, listings: []})
     else
       ListingIndexService::API::Api
         .listings
         .search(
           community_id: community.id,
           search: {
             listing_shape_ids: params[:listing_shapes],
             page: page,
             per_page: per_page
           },
           engine: FeatureFlagHelper.search_engine,
           raise_errors: raise_errors,
           includes: [:listing_images, :author, :location])
     end
  end

  def build_title(community, params)
    category = Category.find_by_id(params["category"])
    category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    listing_type_label = if ["request","offer"].include? params['share_type']
      I18n.translate("listings.index.#{params['share_type']+'s'}")
    else
      I18n.translate("listings.index.listings")
    end

    I18n.translate("listings.index.feed_title",
      :optional_category => category_label,
      :community_name => community.name_with_separator(I18n.locale),
      :listing_type => listing_type_label)
  end

  def updated
    listings.first.present? ? listings.first[:updated_at] : Time.zone.now
  end
end
