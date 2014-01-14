class Admin::CustomFieldsController < ApplicationController
  
  before_filter :ensure_is_admin
  before_filter :custom_fields_allowed
  
  skip_filter :dashboard_only
  
  def index
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_fields = @current_community.custom_fields
  end
  
  def new
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = Dropdown.new
    @custom_field.options = [CustomFieldOption.new, CustomFieldOption.new]
    session[:option_amount] = 2
  end
  
  def create
    success = if valid_categories?(@current_community, params[:custom_field][:category_attributes])
      @custom_field = Dropdown.new(params[:custom_field])
      @custom_field.community = @current_community
      @custom_field.save
    end
    flash[:error] = "Listing field saving failed" unless success
    redirect_to admin_custom_fields_path
  end
  
  def edit
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = CustomField.find(params[:id])
    session[:option_amount] = @custom_field.options.size
  end
  
  def update
    @custom_field = CustomField.find(params[:id])
    @custom_field.update_attributes(params[:custom_field])
    redirect_to admin_custom_fields_path
  end

  def destroy
    @custom_field = Dropdown.find(params[:id])

    success = if custom_field_belongs_to_community?(@custom_field, @current_community)
      @custom_field.destroy
    end

    flash[:error] = "Field doesn't belong to current community" unless success
    redirect_to admin_custom_fields_path
  end
  
  def add_option
    session[:option_amount] += 1
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def order
    sort_priorities = params[:order].each_with_index.map do |custom_field_id, index|
      [custom_field_id, index]
    end.inject({}) do |hash, ids|
      custom_field_id, sort_priority = ids
      hash.merge(custom_field_id.to_i => sort_priority)
    end

    @current_community.custom_fields.each do |custom_field|
      custom_field.update_attributes(:sort_priority => sort_priorities[custom_field.id])
    end

    render nothing: true, status: 200
  end

  private

  # Return `true` if all the category id's belong to `community`
  def valid_categories?(community, category_attributes)
    is_community_category = category_attributes.map do |category|
      community.categories.any? { |community_category| community_category.id == category[:category_id].to_i }
    end

    is_community_category.all?
  end

  # Before filter
  def custom_fields_allowed
    unless @current_community.custom_fields_allowed?
      flash[:error] = "Custom listing fields are not enabled for this community"
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end

  def custom_field_belongs_to_community?(custom_field, community)
    community.custom_fields.include?(custom_field)
  end

end