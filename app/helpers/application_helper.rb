# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Short form for translate method. Integers are not translated.
  def t(*args)
    if (args[0] && args[0].to_i.to_s.eql?(args[0]))
      args
    else  
      translate(*args)
    end  
  end
  
  def ta(array)
    translated_array = Array.new
    index = 0;
    array.each do |array_item|
      translated_array[index] = t(array_item)
      index += 1;
    end
    return translated_array  
  end
  
  # Returns hash containing link names and urls for top navigation.
  def get_top_navi_items
    navi_items = ActiveSupport::OrderedHash.new  
    navi_items[:listings ] = listing_category_path("all_categories")
    navi_items[:items ] = items_path
    navi_items[:favors ] = favors_path
    navi_items[:people ] = people_path
    if (session[:person_id])
      navi_items[:own ] = all_person_listings_path(session[:person_id].to_s)
    end
    return navi_items
  end
  
  # Returns hash containing link names and urls for left navigation.
  def get_left_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    session[:left_navi] = true
    case navi_type
    when 'own'
      navi_items[:listings] = all_person_listings_path(session[:person_id].to_s)
      navi_items[:inbox] = person_inbox_path(session[:person_id].to_s)
      navi_items[:profile] = person_profile_path(session[:person_id].to_s)
      navi_items[:friends] = person_friends_path(session[:person_id].to_s)
      navi_items[:contacts] = person_contacts_path(session[:person_id].to_s)
      navi_items[:purse] = person_purse_path(session[:person_id].to_s)
      navi_items[:settings] = person_settings_path(session[:person_id].to_s)
    when 'listings'
      navi_items[:browse_listings] = listing_category_path("all_categories")
      navi_items[:search_listings] = search_listings_path
      navi_items[:add_listing] = new_listing_path
    when 'items'
      navi_items[:browse_items] = items_path
      navi_items[:search_items] = search_items_path
    when 'favors'
      navi_items[:browse_favors] = favors_path
      navi_items[:search_favors] = search_favors_path
    when 'people'
      navi_items[:browse_people] = people_path
      navi_items[:search_people] = search_people_path      
    else
      session[:left_navi] = false  
    end  
    return navi_items
  end
  
  # Returns hash containing link names and urls for left sub navigation.
  def get_sub_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    case navi_type
    when 'listings'
      navi_items[:all] = all_person_listings_path(session[:person_id].to_s)
      navi_items[:own_listings_navi] = own_person_listings_path(session[:person_id].to_s)
      navi_items[:interesting] = interesting_person_listings_path(session[:person_id].to_s)
    when 'browse_listings'
      navi_items[:all_categories] = listing_category_path("all_categories")
      Listing::MAIN_CATEGORIES.each do |category|
        navi_items[category] = listing_category_path(category)
      end   
    else
      navi_items = nil
    end 
    return navi_items 
  end
  
  # Returns hash containing link names and urls for left "sub sub" navigation.
  def get_sub_sub_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    if (Listing.get_sub_categories(navi_type))
      Listing.get_sub_categories(navi_type).each do |category|
        navi_items[category] = listing_category_path(category)
      end   
    else
      navi_items = nil
    end 
    return navi_items 
  end
  
  def show_listings
  
  end
  
  # Localizes default values of the pagination plugin "will paginate".
  def localize_will_paginate
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = '&laquo; ' + translate(:previous)
    WillPaginate::ViewHelpers.pagination_options[:next_label] = translate(:next) + ' &raquo;'
  end
  
end
