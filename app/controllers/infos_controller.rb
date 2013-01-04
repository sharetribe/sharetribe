class InfosController < ApplicationController

  skip_filter :check_email_confirmation, :dashboard_only
  
  def about
    session[:selected_tab] = "about"
    session[:selected_left_navi_link] = "about"
  end
  
  def how_to_use
    session[:selected_tab] = "about"
    session[:selected_left_navi_link] = "how_to_use"
  end

  def terms
    session[:selected_tab] = "about"
    session[:selected_left_navi_link] = "terms"
  end
  
  def privacy
    session[:selected_tab] = "about"
    session[:selected_left_navi_link] = "privacy"
  end

end
