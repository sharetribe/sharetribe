module ListingsHelper
  
  # Creates a dropdown populated with all valid listing categories
  def get_category_select_box
    categories = Listing.get_valid_categories.collect { |category| [t(category), category] }
    selected = {}
    selected[:selected] = params[:category][:category] if params[:category] && params[:category][:category]
    selected[:include_blank] = t(:all_categories)
    select("category", "category", categories, selected) 
  end

end
