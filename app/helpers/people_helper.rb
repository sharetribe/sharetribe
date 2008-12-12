module PeopleHelper

  # Renders links for profile navi
  def get_profile_navi_items(person_id)
    navi_items = ActiveSupport::OrderedHash.new
    navi_items[:information] = person_path(person_id)
    #navi_items[:friends] = person_friends_path(person_id)
    #navi_items[:contacts] = person_contacts_path(person_id)
    navi_items[:kassi_events] = person_kassi_events_path(person_id)
    navi_items[:listings] = person_listings_path(person_id)
    links = [] 
    navi_items.each do |name, link|
      if name.to_s.eql?(session[:profile_navi])
        if name.eql?(:kassi_events)
          links << t(name) + " <span class='page_entries_info'>(" + page_entries_info(@kassi_events) + ")</span>"
        elsif name.eql?(:listings)
          links << t(name) + " <span class='page_entries_info'>(" + page_entries_info(@listings) + ")</span>"  
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
      relation += t(:listing_illative) + " " + link_to(listing.title, listing_path(listing))
    when "Item"
      item = kassi_event.eventable
      relation += t(:item_illative) + " " + link_to(item.title, item_path(item))
    when "Favor"
      favor = kassi_event.eventable
      relation += t(:favor_illative) + " " + link_to(favor.title, favor_path(favor))
    end
    return relation       
  end

end
