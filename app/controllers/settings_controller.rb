class SettingsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_your_settings"
  end
  
  before_filter do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  def show
  if @person.location == nil
  	@person.location = Location.new(:address => @person.street_address, :latitude => 0,:longitude => 0,:google_address => "", :type => 'person')
        end
    render :action => :profile
  end
  
  def profile
#A helper for transitional phase to using location-model
  end
  
  def avatar
    
  end
  
  def account
    
  end

  def notifications
  end

end
