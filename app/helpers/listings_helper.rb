module ListingsHelper
  
  # Class is selected if listing type is currently selected
  def get_new_listing_tab_class(listing_type)
    "new_listing_form_tab_#{params[:type].eql?(listing_type) ? 'selected' : 'unselected'}"
  end
  
end
