module ListingsHelper
  
  # Class is selected if conversation type is currently selected
  def get_map_tab_class(tab_name)
    current_tab_name = action_name || "map_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
  
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
  
  # Removes extra characters from datetime_select field
  def clear_datetime_select(&block)
    time = "</div><div class='date_select_time_container'><div class='datetime_select_time_label'>#{t('.at')}:</div>"
    colon = "</div><div class='date_select_time_container'><div class='datetime_select_colon_label'>:</div>"
    haml_concat capture_haml(&block).gsub(":", "#{colon}").gsub("&mdash;", "#{time}").gsub("\n", '')
  end
  
  # Class is selected if listing type is currently selected
  def get_listing_tab_class(tab_name)
    current_tab_name = params[:type] || "list_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
  
  def share_type_checkbox_checked?(share_type)
    if @listing.new_record?
      params[:share_type].eql?(share_type) || (@listing.default_share_type?(share_type) && !params[:share_type])
    else  
      @listing.has_share_type?(share_type)
    end  
  end
  
  def visibility_array
    array = []
    Listing::VALID_VISIBILITIES.each do |visibility|
      if visibility.eql?("this_community")
        array << [t(".#{visibility}", :community => @current_community.name), visibility]
      else
        array << [t(".#{visibility}"), visibility]
      end
    end
    return array  
  end
  
end
