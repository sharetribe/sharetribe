class InfosController < ApplicationController

  skip_filter :check_email_confirmation, :dashboard_only

  def about
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "about"
  end

  def how_to_use
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "how_to_use"
  end

  def terms
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "terms"
  end

  def privacy
    @selected_tribe_navi_tab = "about"
    @selected_left_navi_link = "privacy"
  end

end
