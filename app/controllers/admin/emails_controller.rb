class Admin::EmailsController < ApplicationController
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only

  def new
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "email_members"
  end
  
  def create
    redirect_to :action => :new
  end
  
end