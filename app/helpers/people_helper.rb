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
        links << t(name)
      else
        links << link_to(t(name), link)
      end    
    end
    links.join(" | ")
  end

end
