module NavigationHelpers

  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the signup page/
      '/en/signup' 
    when /the requests page/
      '/en/requests'
    when /the offers page/
      '/en/offers'  
    when /the edit listing page/
      edit_listing_path(:id => @listing.id) 
    when /^the give feedback path of "(.*)"$/i
      new_person_message_feedback_path(:person_id => @people[$1].id, :message_id => @conversation.id.to_s)
    when /^the conversation path of "(.*)"$/i
      person_message_path(:person_id => @people[$1].id, :id => @conversation.id.to_s)
    when /^the profile page of "(.*)"$/i
      person_path(:id => @people[$1].id)
    when /^the badges page of "(.*)"$/i
      person_badges_path(:person_id => @people[$1].id)
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
  
end

World(NavigationHelpers)
