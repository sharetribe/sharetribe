module PeopleHelper

  # Renders links for profile navi
  def get_profile_navi_items(person_id)
    navi_items = ActiveSupport::OrderedHash.new
    navi_items[:information] = person_path(person_id)
    navi_items[:friends] = person_friends_path(person_id)
    navi_items[:contacts] = person_contacts_path(person_id)
    navi_items[:kassi_events] = person_kassi_events_path(person_id)
    navi_items[:listings] = person_listings_path(person_id)
    links = [] 
    navi_items.each do |name, link|
      if name.to_s.eql?(session[:profile_navi])
        if name.eql?(:kassi_events)
          links << t(name) + " <span class='page_entries_info'>(" + page_entries_info(@kassi_events) + ")</span>"
        elsif name.eql?(:listings)
          links << t(name) + " <span class='page_entries_info'>(" + page_entries_info(@listings) + ")</span>"
        elsif name.eql?(:contacts)
          links << t(name) + " <span class='page_entries_info'>(" + page_entries_info(@contacts) + ")</span>"
        elsif name.eql?(:friends)
          links << t(name) # + " <span class='page_entries_info'>(" + page_entries_info(@friends) + ")</span>"      
        else
          links << t(name)
        end  
      else
        links << link_to(t(name), link)
      end    
    end
    links.join(" | ")
  end

  def get_kassi_event_relation(kassi_event)
    relation = t(:comment_is_related_to) + " "
    case kassi_event.eventable_type
    when "Listing"
      listing = kassi_event.eventable
      relation += t(:listing_illative) + " " + link_to(h(listing.title), listing_path(listing))
    when "Item"
      item = kassi_event.eventable
      if item.status.eql?("disabled")
        relation += t(:item_illative) + " " + h(item.title) + " (" + t(:item_removed_at) + ")"
      else  
        relation += t(:item_illative) + " " + link_to(h(item.title), item_path(h(item.title)) + "#" + item.id.to_s)
      end  
    when "Favor"
      favor = kassi_event.eventable
      if favor.status.eql?("disabled")
        relation += t(:favor_illative) + " " + h(favor.title) + " (" + t(:favor_removed_at) + ")"
      else  
        relation += t(:favor_illative) + " " + link_to(h(favor.title), favor_path(h(favor.title)) + "#" + favor.id.to_s)
      end
    end
    return relation       
  end
  
  def get_friend_status_link(person)
    friend_status = person.friend_status(session[:cookie])
    case friend_status
    when "friend"
      link_to t(:remove_from_friends), person_friend_path(@current_user, person), :method => :delete 
    when "none"
      link_to t(:add_as_friend), person_friends_path(person), :method => :post 
    when "requested"
      link_to t(:cancel_friend_request), cancel_person_request_path(@current_user, person), :method => :post
    when "pending"
      link_to t(:accept_friend_request), accept_person_request_path(@current_user, person), :method => :post
    end
  end

end
