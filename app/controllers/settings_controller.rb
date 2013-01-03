class SettingsController < ApplicationController
  
  layout "no_tribe"
  
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end
  
  before_filter do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  skip_filter :dashboard_only
  
  def show
    session[:no_tribe_title] = "settings"
    session[:selected_left_navi_link] = "profile"
    add_location_to_person
    render :action => :profile
  end
  
  def profile
    session[:no_tribe_title] = "settings"
    session[:selected_left_navi_link] = "profile"
    # This is needed if person doesn't yet have a location
    # Build a new one based on old street address or then empty one.
    add_location_to_person
  end
  
  def avatar
    session[:no_tribe_title] = "settings"
    session[:selected_left_navi_link] = "avatar"
  end
  
  def account
    session[:no_tribe_title] = "settings"
    session[:selected_left_navi_link] = "account"
  end

  def notifications
    session[:no_tribe_title] = "settings"
    session[:selected_left_navi_link] = "notifications"
  end
  
  private
  
  def add_location_to_person  
    unless @person.location
      @person.build_location(:address => @person.street_address,:location_type => 'person')
      @person.location.search_and_fill_latlng
    end
  end

end
