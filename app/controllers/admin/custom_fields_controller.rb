class Admin::CustomFieldsController < ApplicationController

  before_filter :ensure_is_admin
  before_filter :field_type_is_valid, :only => [:new, :create]

  skip_filter :dashboard_only

  def index
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_fields = @current_community.custom_fields
  end

  def new
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = params[:field_type].constantize.new #before filter checks valid field types and prevents code injection

    if params[:field_type] == "CheckboxField"
      @min_option_count = 1
      @custom_field.options = [CustomFieldOption.new]
    else
      @min_option_count = 2
      @custom_field.options = [CustomFieldOption.new, CustomFieldOption.new]
    end
  end

  def create
    @selected_left_navi_link = "listing_fields"
    @community = @current_community

    # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
    params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
    params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

    @custom_field = params[:field_type].constantize.new(params[:custom_field]) #before filter checks valid field types and prevents code injection
    @custom_field.community = @current_community

    success = if valid_categories?(@current_community, params[:custom_field][:category_attributes])
      @custom_field.save
    end

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Listing field saving failed"
      render :new
    end
  end

  def edit
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community

    if params[:field_type] == "CheckboxField"
      @min_option_count = 1
    else
      @min_option_count = 2
    end

    @custom_field = CustomField.find(params[:id])
  end

  def update
    @custom_field = CustomField.find(params[:id])

    # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
    params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
    params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

    @custom_field.update_attributes(params[:custom_field])

    redirect_to admin_custom_fields_path
  end

  def edit_price
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
  end

  def edit_location
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
  end

  def update_price
    # To cents
    params[:community][:price_filter_min] = (params[:community][:price_filter_min].to_i * 100) if params[:community][:price_filter_min]
    params[:community][:price_filter_max] = (params[:community][:price_filter_max].to_i * 100) if params[:community][:price_filter_max]

    success = @current_community.update_attributes(params[:community])

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Price field editing failed"
      render :action => :edit_price
    end
  end

  def update_location
    success = @current_community.update_attributes(params[:community])

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Location field editing failed"
      render :action => :edit_location
    end
  end

  def destroy
    @custom_field = CustomField.find(params[:id])

    success = if custom_field_belongs_to_community?(@custom_field, @current_community)
      @custom_field.destroy
    end

    flash[:error] = "Field doesn't belong to current community" unless success
    redirect_to admin_custom_fields_path
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

  def custom_field_belongs_to_community?(custom_field, community)
    community.custom_fields.include?(custom_field)
  end

  private

  def field_type_is_valid
    redirect_to admin_custom_fields_path unless CustomField::VALID_TYPES.include?(params[:field_type])
  end

end
