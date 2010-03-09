module VisibilityHelper

  # Returns visibility conditions for object_type (item, favor or listing)
  def get_visibility_conditions(object_type, person=@current_user, cookie = nil)
    cookie ||= session[:cookie] unless cookie
    conditions = " AND (visibility = 'everybody'"
    if person
      case object_type
      when "listing"
        person_type = "author_id"
      when "item"
        person_type = "owner_id"
      when "favor"
        person_type = "owner_id"
      end
      conditions += " OR visibility = 'kassi_users' OR #{person_type} = '#{person.id}'"
      friend_ids = person.get_friend_ids(cookie)
      if friend_ids.size > 0
        conditions += " OR (visibility IN ('friends', 'f_c', 'f_g', 'f_c_g') 
        AND #{person_type} IN (" + friend_ids.collect { |id| "'#{id}'" }.join(",") + "))"
      end
      if Person.count_by_sql(person.contact_query("COUNT(people.id)")) > 0
        conditions += " OR (visibility IN ('contacts', 'f_c', 'c_g', 'f_c_g') 
        AND #{person_type} IN (#{person.contact_query('people.id')}))"
      end
      if person.groups(cookie).size > 0
        group_ids = person.get_group_ids(cookie).collect { |id| "'#{id}'" }.join(",")
        conditions += " OR (visibility IN ('groups', 'f_g', 'c_g', 'f_c_g')
        AND id IN (
        SELECT #{object_type}s.id 
        FROM groups_#{object_type}s, #{object_type}s
        WHERE groups_#{object_type}s.group_id IN (#{group_ids})
        AND groups_#{object_type}s.#{object_type}_id = #{object_type}s.id
        ))"
      end
    end
    conditions += ")"
  end
  
  # Returns the visibility value to be saved in db based 
  # on the visibility parameter and checkbox values
  def get_visibility(object_type)
    # Use the method in ApplicationHelper
    set_visibility_in_params(object_type)
  end
  
  # Sets the visibility value to be saved in db based 
  # on the visibility parameter and checkbox values
  def set_visibility_in_params(object_type)
    if params[object_type][:visibility].eql?("other")
      if params[:friends]
        if params[:contacts]
          if params[:groups]
            params[object_type][:visibility] = "f_c_g"
          else  
            params[object_type][:visibility] = "f_c"
          end  
        else
          if params[:groups]
            params[object_type][:visibility] = "f_g"
          else
            params[object_type][:visibility] = "friends"
          end  
        end  
      else
        if params[:contacts]
          if params[:groups]
            params[object_type][:visibility] = "c_g"
          else
            params[object_type][:visibility] = "contacts"
          end    
        else
          if params[:groups]
            params[object_type][:visibility] = "groups"
          else  
            params[object_type][:visibility] = "none"
          end  
        end  
      end
    end
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