class Admin::CustomFieldsController < ApplicationController
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def index
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = DropdownField.new
    @custom_fields = @current_community.categories.flat_map(&:custom_fields).uniq.sort
    @custom_field.options = [CustomFieldOption.new, CustomFieldOption.new]
    session[:option_amount] = 2
  end
  
  def create
    @custom_field = DropdownField.new(params[:custom_field])
    success = @custom_field.save

    flash[:error] = "Listing field saving failed" unless success

    redirect_to admin_custom_fields_path
  end

  def destroy
    @custom_field = DropdownField.find(params[:id])
    success = @custom_field.destroy
    redirect_to admin_custom_fields_path
  end
  
  def add_option
    session[:option_amount] += 1
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
end