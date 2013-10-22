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
end
