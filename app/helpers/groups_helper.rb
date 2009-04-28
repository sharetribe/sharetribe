module GroupsHelper
  
  def get_join_or_leave_group_link(group)
    if @current_user 
      if group.is_member?(@current_user, session[:cookie])
        return link_to(t(:leave_group), leave_person_group_path(@current_user, group), :method => :delete)
      else
        return link_to(t(:join_group), join_person_group_path(@current_user, group), :method => :post)
      end   
    end  
  end
  
end
