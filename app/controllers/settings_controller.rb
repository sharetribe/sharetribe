class SettingsController < ApplicationController
  
  layout "settings"
  
  before_filter :except => :unsubscribe do |controller|
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
  
  def unsubscribe
    @person_to_unsubscribe = @current_user
    
    # Check if trying to unsubscribe with expired token and allow that
    if @person_to_unsubscribe.nil? && session[:auth_token_expired]
      @person_to_unsubscribe = AuthToken.find_by_token(params[:auth]).person
    end
    
    if @person_to_unsubscribe && @person_to_unsubscribe.id == params[:person_id]
      if params[:email_type] == "community_updates"
        @person_to_unsubscribe.preferences["email_about_weekly_events"] = false
        @person_to_unsubscribe.save
        render :unsubscribe, :layout => "application" 
      end
      
    else
      
      # display some message
      
      # 
    end
  end
  
  private
  
  def add_location_to_person  
    unless @person.location
      @person.build_location(:address => @person.street_address,:location_type => 'person')
      @person.location.search_and_fill_latlng
    end
  end

end
