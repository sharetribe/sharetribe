class SettingsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_your_settings"
  end
  
  before_filter do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  def show
    add_location_to_person
    render :action => :profile
  end
  
  def profile
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
    # TODO (No-ASI) This looks like it's not needed. Now commented away. Remove if everything works and tests pass.
    # unless @person.location
    #      @person.build_location(:address => @person.street_address,:type => 'person')
    #      @person.location.search_and_fill_latlng
    #    end
  end

end
