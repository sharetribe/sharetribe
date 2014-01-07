class Admin::CustomFieldsController < ApplicationController
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def index
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = CustomField.new
    @custom_field.options.build
    @custom_fields = @current_community.categories.flat_map(&:custom_fields).uniq.sort
    session[:option_amount] = 1
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
  
  def add_option
    session[:option_amount] += 1
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def remove_option
    session[:option_amount] -= 1
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
end