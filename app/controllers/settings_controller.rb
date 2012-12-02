class SettingsController < ApplicationController
  
  layout "settings"
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_your_settings"
  end
  
  before_filter do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  skip_filter :dashboard_only
  
  def show
    add_location_to_person
    render :action => :profile
  end
  
  def profile
    # This is needed if person doesn't yet have a location
    # Build a new one based on old street address or then empty one.
    add_location_to_person
  end
  
  def avatar
    
  end
  
  def account
    
  end

  def notifications
  end
  
  private
  
  def add_location_to_person  
    unless @person.location
      @person.build_location(:address => @person.street_address,:location_type => 'person')
      @person.location.search_and_fill_latlng
    end
  end

end
