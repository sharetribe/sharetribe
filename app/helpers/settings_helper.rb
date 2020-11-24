module SettingsHelper

  # Class is selected if conversation type is currently selected
  def get_settings_tab_class(tab_name)
    current_tab_name = (action_name.eql?("show")) ? "profile" : action_name
    "inbox_tab_#{current_tab_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end
end
