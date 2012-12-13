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
    time = "</div><div class='date_select_time_container'><div class='datetime_select_time_label'>#{t('listings.form.departure_time.at')}:</div>"
    colon = "</div><div class='date_select_time_container'><div class='datetime_select_colon_label'>:</div>"
    haml_concat capture_haml(&block).gsub(":", "#{colon}").gsub("&mdash;", "#{time}").gsub("\n", '').html_safe
  end
  
  # Class is selected if listing type is currently selected
  def get_listing_tab_class(tab_name)
    current_tab_name = params[:type] || "list_view"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
  
  def share_type_array
    Listing::VALID_SHARE_TYPES[@listing.listing_type][@listing.category].sort { |a,b| a <=> b }.collect { |st| [t(".#{st}"), st] }
  end
  
  def visibility_array
    array = []
    Listing::VALID_VISIBILITIES.each do |visibility|
      if visibility.eql?("this_community")
        array << [t(".#{visibility}", :community => @current_community.name), visibility]
      elsif !(visibility.eql?("communities") && @current_user.communities.size < 2) 
        array << [t(".#{visibility}"), visibility]
      end
    end
    return array  
  end
  
  def privacy_array
    Listing::VALID_PRIVACY_OPTIONS.collect { |option| [t(".#{option}"), option] }
  end
  
  def listed_listing_title(listing)
    if listing.share_type
      if listing.share_type.eql?("trade")
        t("listings.show.#{listing.category}_#{listing.listing_type}_#{listing.share_type}") + ": #{listing.title}"
      else
        t("common.share_types.#{listing.share_type}").capitalize + ": #{listing.title}"
      end
    else
      t("listings.show.#{listing.category}_#{listing.listing_type}") + ": #{listing.title}"
    end
  end
  
  # expects category_string to be "item", "favor", "rideshare" or "housing"
  def localized_category_label(category_string)
    return nil if category_string.nil?
    category_string += "s" if ["item", "favor"].include?(category_string)
    return t("listings.index.#{category_string}")
  end
  
end
