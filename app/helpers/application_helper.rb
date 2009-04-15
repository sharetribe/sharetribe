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
  
  # Returns a hash containing link names and urls for top navigation.
  def get_top_navi_items
    navi_items = ActiveSupport::OrderedHash.new  
    navi_items[:listings ] = listing_category_path("all_categories")
    navi_items[:items ] = items_path
    navi_items[:favors ] = favors_path
    navi_items[:people ] = people_path
    navi_items[:groups_title] = groups_path
    if @current_user
      navi_items[:own] = home_person_path(@current_user)
      if @current_user.is_admin == 1
        navi_items[:admin] = admin_feedbacks_path
      end  
    end
    return navi_items
  end
  
  # Returns a hash containing link names and urls for left navigation.
  def get_left_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    session[:left_navi] = true
    case navi_type
    when 'own'
      navi_items[:home] = home_person_path(@current_user)
      navi_items[:inbox] = person_inbox_index_path(@current_user)
      navi_items[:profile] = person_path(@current_user)
      navi_items[:friends] = person_friends_path(@current_user)
      navi_items[:contacts] = person_contacts_path(@current_user)
      navi_items[:kassi_events] = person_kassi_events_path(@current_user)
      navi_items[:own_listings] = person_listings_path(@current_user)
      navi_items[:requests] = person_requests_path(@current_user)
      navi_items[:comments_to_own_listings] = comments_person_listings_path(@current_user)
      navi_items[:settings] = person_settings_path(@current_user)
      #navi_items[:interesting_listings] = interesting_person_listings_path(@current_user)
      #navi_items[:purse] = person_purse_path(@current_user)
    when 'listings'
      navi_items[:browse_listings] = listing_category_path("all_categories")
      navi_items[:search_listings] = search_listings_path
      navi_items[:add_listing] = new_listing_path
    when 'items'
      navi_items[:browse_items] = items_path
      navi_items[:search_items] = search_items_path
      navi_items[:add_item] = person_path(@current_user) + "#items" if @current_user
      navi_items[:request_item] = new_listing_path(:category => "borrow_items")
    when 'favors'
      navi_items[:browse_favors] = favors_path
      navi_items[:search_favors] = search_favors_path
      navi_items[:add_favor] = person_path(@current_user) + "#favors" if @current_user
      navi_items[:request_favor] = new_listing_path(:category => "favors")
    when 'people'
      navi_items[:browse_people] = people_path
      navi_items[:search_people] = search_people_path
    when 'groups_title'
      navi_items[:browse_groups] = groups_path
      #navi_items[:search_groups] = search_groups_path
      navi_items[:new_group] = new_group_path
    when 'info'
      navi_items[:about] = about_info_path
      navi_items[:help] = help_info_path
      navi_items[:terms] = terms_info_path      
    else
      session[:left_navi] = false  
    end  
    return navi_items
  end
  
  # Returns a hash containing link names and urls for left sub navigation.
  def get_sub_navi_items(navi_type)
    navi_items = ActiveSupport::OrderedHash.new
    case navi_type
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
  
  # Returns a hash containing link names and urls for left "sub sub" navigation.
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
  
  def is_current_user?(person)
    if @current_user
      return person.id == @current_user.id ? true : false 
    else
      return false
    end    
  end
  
  # Create "show [link_value] listings on page" links for 
  # each link value. Type defines the link target path.
  def create_footer_pagination_links(link_values, type)
    links = []
    per_page_value = params[:per_page] || "10"
    params[:page] = 1 if params[:page]
    link_values.each do |value|
      if per_page_value.eql?(value)
        links << t(value)
      else
        case type
        when "category"
          if params[:id]
            path = listing_category_path(params.merge({:per_page => value}))
          else
            path = listing_category_path("all_categories", :per_page => value)
          end 
        when "interesting_listings"
          path = interesting_person_listings_path(params.merge({:per_page => value}))
        when "person_listings"
          path = person_listings_path(params.merge({:per_page => value}))       
        when "search_listings"
          path = search_listings_path(params.merge({:per_page => value}))
        when "search_items"
          path = search_items_path(params.merge({:per_page => value}))  
        when "search_all"
          path = search_path(params.merge({:per_page => value})) 
        when "kassi_events"
          path = person_kassi_events_path(params.merge({:per_page => value}))
        when "inbox"
          path = person_inbox_index_path(params.merge({:per_page => value}))
        when "sent_messages"
          path = sent_person_inbox_path(params.merge({:per_page => value}))   
        when "kassi_users"
          path = people_path(params.merge({:per_page => value}))
        when "contacts"
          path = person_contacts_path(params.merge({:per_page => value}))
        when "friends"
          path = person_friends_path(params.merge({:per_page => value}))    
        when "comments"
          path = comments_person_listings_path(params.merge({:per_page => value}))
        when "requests"
          path = person_requests_path(params.merge({:per_page => value}))
        when "search_people"
          path = search_people_path(params.merge({:per_page => value}))
        when "feedback"
          path = admin_feedbacks_path(params.merge({:per_page => value}))
        when "groups_title"
          path = groups_path(params.merge({:per_page => value}))
        when "group_members"
          path = group_path(params.merge({:per_page => value}))                      
        end
        links << link_to(t(value), path)  
      end    
    end
    links.join(" | ")  
  end
  
  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks(text)
    #pattern for ending characters that are not part of the url
    pattern = /[\.)]*$/
    h(text).gsub(/https?:\/\/\S+/) { |link_url| link_to(link_url.gsub(pattern,""), link_url.gsub(pattern,"")) +  link_url.match(pattern)[0]}.gsub(/\n/, "<br />")
  end
  
  def small_avatar_thumb(person)
    link_to (image_tag COS_URL + "/people/" + person.id + "/@avatar/small_thumbnail", 
              :alt => person.name(session[:cookie]), :width => 50, :height => 50), person  
  end
  
  def large_avatar_thumb(person)
    image_tag COS_URL + "/people/" + person.id + "/@avatar/large_thumbnail", 
              :alt => person.name(session[:cookie])
  end
  
  def translate_announcement_error_message(message)
    case message
    when "Title is required"
      :title_is_required
    when "Title on liian lyhyt (minimi on 2 merkkiä)."
      :title_is_too_short
    when "Title is too short (minimum is 2 characters)"
      :title_is_too_short  
    when "Title on liian pitkä (maksimi on 70 merkkiä)."
      :title_is_too_long
    when "Title item_with_proposed_title_already_exists"
      :item_title_with_same_name_already_exists
    when "Title favor_with_proposed_title_already_exists"
      :favor_title_with_same_name_already_exists  
    when "Description is too long"    
      :description_is_too_long 
    else
      message
    end  
  end
  
  def refresh_announcements(page)
    page["announcement_div"].replace_html :partial => 'layouts/announcements'
  end
  
  def has_address?(person)
    if person.street_address && person.street_address != ""
      return true
    end
    return false  
  end
  
  # Returns checkboxes for item, favor and listing visibility settings
  def get_visibility_checkboxes(visibility = nil, groups = nil)
    checkboxes = []
    box_values = {
      "friends" => "checked",
      "contacts" => "checked", 
    }
    if visibility
      case visibility
      when "friends"
        box_values["contacts"] = nil
      when "contacts"
        box_values["friends"] = nil
      when "f_g"
        box_values["contacts"] = nil
      when "c_g"      
        box_values["friends"] = nil
      when "none"
        box_values["friends"] = nil
        box_values["contacts"] = nil
      when "groups"
        box_values["friends"] = nil
        box_values["contacts"] = nil  
      end     
    end
    box_values.each do |name, value|
      if value
        checkboxes << check_box_tag(name, "true", :checked => "checked") + " &nbsp; " + t(name)
      else
        checkboxes << check_box_tag(name, "true") + " &nbsp; " + t(name)
      end    
    end
    @current_user.groups(session[:cookie]).each do |group|
      if groups && groups.size > 0 && groups.include?(group)
        checkboxes << check_box_tag("groups[]", group.id.to_s, :checked => "checked") + " &nbsp; " + group.title(session[:cookie])
      else
        checkboxes << check_box_tag("groups[]", group.id.to_s) + " &nbsp; " + group.title(session[:cookie])  
      end  
    end
    return checkboxes.join("<br />")
  end
end

# Overrides 'page_entries_info' method of will paginate plugin so that the messages
# it provides can be translated.
module WillPaginate
  module ViewHelpers
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name] ||
        (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
      
      if collection.total_pages < 2
        case collection.size
        when 0; "0"
        when 1; "1"
        else;   "#{collection.size}/#{collection.size}"
        end
      else
        %{%d-%d/%d} % [
          collection.offset + 1,
          collection.offset + collection.length,
          collection.total_entries
        ]
      end
    end
  end
end
