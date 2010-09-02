class SettingsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_your_settings"
  end
  
  before_filter do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  def show
    render :action => :profile
  end
  
  def profile
    
  end
  
  def avatar
    
  end
  
  def account
    
  end

  def notifications
  end

end
