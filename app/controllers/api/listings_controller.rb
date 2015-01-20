class Api::ListingsController < Api::ApiController
  include ListingsHelper

  respond_to :atom

  def index
    @listings = Listing.find_with(params, @current_user, @current_community, @per_page, @page)

    @total_pages = @listings.total_pages

    category = Category.find_by_id(params["category"])
    @category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    if ["request","offer"].include?params['share_type']
      listing_type_label = t("listings.index.#{params['share_type']+"s"}")
    else
      listing_type_label = t("listings.index.listings")
    end

    @title = t("listings.index.feed_title",
               :optional_category => @category_label,
               :community_name => @current_community.name_with_separator(I18n.locale),
               :listing_type => listing_type_label)
    @updated = @listings.first.present? ? @listings.first.updated_at : Time.now

    respond_with @listings
  end
end
