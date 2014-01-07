class Admin::CustomFieldsController < ApplicationController
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def index
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = CustomField.new
  end
  
  def create
    @custom_field = CustomField.create(params[:custom_field])
    redirect_to admin_custom_fields_path
  end

  def destroy
    @custom_field = CustomField.find(params[:id])
    success = @custom_field.destroy
    redirect_to admin_custom_fields_path
  end
  
end