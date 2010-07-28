module ListingsHelper
  
  # Class is selected if listing type is currently selected
  def get_new_listing_tab_class(listing_type)
    "new_listing_form_tab_#{@listing.listing_type.eql?(listing_type) ? 'selected' : 'unselected'}"
  end
  
  # Class is selected if category is currently selected
  def get_type_select_icon_class(category)
    "listing_type_select_icon_#{@listing.category.eql?(category) ? 'selected' : 'unselected'}_#{category}"
  end
  
  # The classes the checkbox gets depend on to which categories its' share type belongs to.
  def get_share_type_checkbox_classes(share_type)
    classes = ""
    Listing::VALID_CATEGORIES.each do |category|
      if Listing::VALID_SHARE_TYPES[@listing.listing_type][category] &&
         Listing::VALID_SHARE_TYPES[@listing.listing_type][category].include?(share_type)
        classes += "#{category} "
      end  
    end
    classes  
  end
  
end
