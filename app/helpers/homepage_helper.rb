module HomepageHelper
  def filters_in_use?
    params[:q].present? || 
    (params[:category].present? && params[:category] != "all") || 
    (params[:share_type].present? && params[:share_type] != "all")
  end

  def show_subcategory_list(category, current_category_id)
    category.id == current_category_id || category.children.any? do |child_category|
      child_category.id == current_category_id
    end
  end

  def all_categories_selected(category_param)
    category_param.nil? || category_param == "all"
  end

  def with_first_listing_image(listing, &block)
    if listing.listing_images.size > 0 && !listing.listing_images.first.image_processing
      block.call(listing.listing_images.first)
    end
  end

  def with_first_listing_image_processing(listing, &block)
    if listing.listing_images.size > 0 && listing.listing_images.first.image_processing
      block.call
    end
  end

  def without_listing_image(listing, &block)
    if listing.listing_images.size == 0
      block.call
    end
  end
end