module HomepageHelper
  def filters_in_use?
    params[:q].present? || 
    (params[:category].present? && params[:category] != "all") || 
    (params[:share_type].present? && params[:share_type] != "all")
  end

  def show_subcategory_list(category, current_category_name, community_categories)
    category.name == current_category_name || category.children.any? do |child_category|
      child_category.name == current_category_name && community_categories.include?(child_category)
    end
  end

  def has_subcategories(category, community_categories)
    category.children.any? { |child_category| community_categories.include?(child_category) }
  end

  def all_categories_selected(current_category_name, main_community_categories, community_categories)
    # category "all" -> all selected
    if current_category_name == "all" then
      true

    # category empty or null -> all selected
    elsif current_category_name == "" || !current_category_name then
      true

    # category set, but it's not community's category -> all selected
    elsif !main_community_categories.any? { |main_category| main_category.name == current_category_name } && 
      !community_categories.any? { |sub_category| sub_category.name == current_category_name } then
      true

    # otherwise -> all is not selected
    else
      return false
    end
  end

  def with_first_listing_image(listing, &block)
    if listing.listing_images.size > 0 && !listing.listing_images.first.image_processing
      block.call
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