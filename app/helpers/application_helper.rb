# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Short form for translate method
  def t(*args)
    translate(*args)
  end
  
  def ta(array)
    translated_array = []
    array.each do |array_item|
      translated_array[] = translate(array_item)
    end
    return translated_array  
  end
  
  # Returns true if array is an array and contains at least one item.
  def usable?(array)
    defined?(array) && array && array.size > 0
  end
  
  # Returns hash containing link names and urls for top navigation.
  def get_top_navi_items
    navi_items = ActiveSupport::OrderedHash.new  
    navi_items[:listings ] = "/listings/categories/all_categories"
    navi_items[:items ] = "/items"
    navi_items[:favors ] = "/favors"
    navi_items[:people ] = "/people"
    if (session[:person_id])
      navi_items[:own ] = "/people/" + session[:person_id].to_s + "/listings/all"
    end
    return navi_items
  end
  
  # Returns hash containing link names and urls for left navigation.
  def get_left_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    session[:left_navi] = true
    case navi_type
    when 'own'
      navi_items[:listings] = "/people/" + session[:person_id].to_s + "/listings/all"
      navi_items[:inbox] = "/people/" + session[:person_id].to_s + "/inbox"
      navi_items[:profile] = "/people/" + session[:person_id].to_s + "/profile"
      navi_items[:friends] = "/people/" + session[:person_id].to_s + "/friends"
      navi_items[:contacts] = "/people/" + session[:person_id].to_s + "/contacts"
      navi_items[:purse] = "/people/" + session[:person_id].to_s + "/purse"
      navi_items[:settings] = "/people/" + session[:person_id].to_s + "/settings"
    when 'listings'
      navi_items[:browse_listings] = "/listings/categories/all_categories"
      navi_items[:search_listings] = "/listings/search"
      navi_items[:add_listing] = "/listings/add"
    when 'items'
      navi_items[:browse_items] = "/items"
      navi_items[:search_items] = "/items/search"
    when 'favors'
      navi_items[:browse_favors] = "/favors"
      navi_items[:search_favors] = "/favors/search"
    when 'people'
      navi_items[:browse_people] = "/people"
      navi_items[:search_people] = "/people/search"      
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
      navi_items[:all] = "/people/" + session[:person_id].to_s + "/listings/all"
      navi_items[:own_listings_navi] = "/people/" + session[:person_id].to_s + "/listings/own"
      navi_items[:interesting] = "/people/" + session[:person_id].to_s + "/listings/interesting"
    when 'browse_listings'
      navi_items[:all_categories] = "/listings/categories/all_categories" 
      navi_items[:marketplace] = "/listings/categories/marketplace"
      navi_items[:borrow_items] = "/listings/categories/borrow_items"
      navi_items[:lost_property] = "/listings/categories/lost_property"
      navi_items[:rides] = "/listings/categories/rides"
      navi_items[:groups] = "/listings/categories/groups"
      navi_items[:favors] = "/listings/categories/favors"
      navi_items[:others] = "/listings/categories/others"
    else
      navi_items = nil
    end 
    return navi_items 
  end
  
  # Returns hash containing link names and urls for left "sub sub" navigation.
  def get_sub_sub_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    case navi_type
    when 'marketplace'
      navi_items[:sell] = "/listings/categories/sell" 
      navi_items[:buy] = "/listings/categories/buy" 
      navi_items[:give] = "/listings/categories/give" 
    else
      navi_items = nil
    end 
    return navi_items 
  end
  
end
