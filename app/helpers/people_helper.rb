module PeopleHelper
  
  # Class is selected if listing type is currently selected
  def get_profile_tab_class(tab_name)
    current_tab_name = params[:type] || "offers"
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
  
end
