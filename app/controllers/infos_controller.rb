class InfosController < ApplicationController

  layout "infos"
  skip_filter :check_email_confirmation, :dashboard_only
  
  def about
    session[:selected_tab] = "about"
  end
  
  def how_to_use
    session[:selected_tab] = "about"
  end

  def terms
    session[:selected_tab] = "about"
  end
  
  def register_details
    session[:selected_tab] = "about"
  end

end
