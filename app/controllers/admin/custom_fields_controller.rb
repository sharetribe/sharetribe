class Admin::CustomFieldsController < Admin::AdminBaseController

  before_action :field_type_is_valid, :only => [:new, :create]

  CHECKBOX_TO_BOOLEAN = ->(v) {
    if v == false || v == true
      v
    elsif v == "1"
      true
    else
      false
    end
  }

  HASH_VALUES = ->(v) {
    if v.is_a?(Array)
      v
    elsif v.is_a?(Hash)
      v.values
    elsif v == nil
      nil
    else
      raise ArgumentError.new("Illegal argument given to transformer: #{v.to_inspect}")
    end
  }

  CategoryAttributeSpec = EntityUtils.define_builder(
    [:category_id, :fixnum, :to_integer, :mandatory]
  )

  OptionAttribute = EntityUtils.define_builder(
    [:id, :mandatory],
    [:sort_priority, :fixnum, :to_integer, :mandatory],
    [:title_attributes, :hash, :to_hash, :mandatory]
  )

  CUSTOM_FIELD_SPEC = [
    [:name_attributes, :hash, :mandatory],
    [:category_attributes, collection: CategoryAttributeSpec],
    [:sort_priority, :fixnum, :optional],
    [:required, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ]

  TextFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  NumericFieldSpec = [
    [:min, :mandatory],
    [:max, :mandatory],
    [:allow_decimals, :bool, :mandatory, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DropdownFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
  ] + CUSTOM_FIELD_SPEC

  CheckboxFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DateFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  TextFieldEntity     = EntityUtils.define_builder(*TextFieldSpec)
  NumericFieldEntity  = EntityUtils.define_builder(*NumericFieldSpec)
  DropdownFieldEntity = EntityUtils.define_builder(*DropdownFieldSpec)
  CheckboxFieldEntity = EntityUtils.define_builder(*CheckboxFieldSpec)
  DateFieldEntity     = EntityUtils.define_builder(*DateFieldSpec)

  def index
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_fields = @current_community.custom_fields

    shapes = @current_community.shapes
    price_in_use = shapes.any? { |s| s[:price_enabled] }

    make_onboarding_popup
    render locals: { show_price_filter: price_in_use }
  end

  def new
    @selected_left_navi_link = "listing_fields"
    @community = @current_community
    @custom_field = params[:field_type].constantize.new #before filter checks valid field types and prevents code injection

    if params[:field_type] == "CheckboxField"
      @min_option_count = 1
      @custom_field.options = [CustomFieldOption.new(sort_priority: 1)]
    else
      @min_option_count = 2
      @custom_field.options = [CustomFieldOption.new(sort_priority: 1), CustomFieldOption.new(sort_priority: 2)]
    end
  end

  def create
    @selected_left_navi_link = "listing_fields"
    @community = @current_community

    # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
    params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
    params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

    custom_field_entity = build_custom_field_entity(params[:field_type], params[:custom_field])

    @custom_field = params[:field_type].constantize.new(custom_field_entity) #before filter checks valid field types and prevents code injection
    @custom_field.entity_type = :for_listing
    @custom_field.community = @current_community

    success =
      if valid_categories?(@current_community, params[:custom_field][:category_attributes])
        @custom_field.save
      else
        false
      end

    if success
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:custom_field_created, @custom_field)
      if state_changed
        record_event(flash, "km_record", {km_event: "Onboarding filter created"})
        flash[:show_onboarding_popup] = true
      end

      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Listing field saving failed"
      render :new
    end
  end

  def build_custom_field_entity(type, params)
    params = params.respond_to?(:to_unsafe_hash) ? params.to_unsafe_hash : params
    case type
    when "TextField"
      TextFieldEntity.call(params)
    when "NumericField"
      NumericFieldEntity.call(params)
    when "DropdownField"
      DropdownFieldEntity.call(params)
    when "CheckboxField"
      CheckboxFieldEntity.call(params)
    when "DateField"
      DateFieldEntity.call(params)
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

    @custom_field = @current_community.custom_fields.find(params[:id])
  end

  def update
    @custom_field = @current_community.custom_fields.find(params[:id])

    # Hack for comma/dot issue. Consider creating an app-wide comma/dot handling mechanism
    params[:custom_field][:min] = ParamsService.parse_float(params[:custom_field][:min]) if params[:custom_field][:min].present?
    params[:custom_field][:max] = ParamsService.parse_float(params[:custom_field][:max]) if params[:custom_field][:max].present?

    custom_field_params = params[:custom_field].merge(
      sort_priority: @custom_field.sort_priority
    )

    custom_field_entity = build_custom_field_entity(@custom_field.type, custom_field_params)

    @custom_field.update_attributes(custom_field_entity)

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

  def edit_expiration
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "listing_fields"
    @community = @current_community

    render_expiration_form(listing_expiration_enabled: !@current_community.hide_expiration_date)
  end

  def update_price
    # To cents
    params[:community][:price_filter_min] = MoneyUtil.parse_str_to_money(params[:community][:price_filter_min], @current_community.currency).cents if params[:community][:price_filter_min]
    params[:community][:price_filter_max] = MoneyUtil.parse_str_to_money(params[:community][:price_filter_max], @current_community.currency).cents if params[:community][:price_filter_max]

    price_params = params.require(:community).permit(
      :show_price_filter,
      :price_filter_min,
      :price_filter_max
    )

    success = @current_community.update_attributes(price_params)

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Price field editing failed"
      render :action => :edit_price
    end
  end

  def update_location
    location_params = params.require(:community).permit(:listing_location_required)

    success = @current_community.update_attributes(location_params)

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Location field editing failed"
      render :action => :edit_location
    end
  end

  def update_expiration
    listing_expiration_enabled = params[:listing_expiration_enabled] == "enabled"

    success = @current_community.update_attributes(
      { hide_expiration_date: !listing_expiration_enabled })

    if success
      redirect_to admin_custom_fields_path
    else
      flash[:error] = "Expiration field editing failed"
      render_expiration_form(listing_expiration_enabled: !@current_community.hide_expiration_date)
    end
  end

  def render_expiration_form(listing_expiration_enabled:)
    render :edit_expiration, locals: {
             listing_expiration_enabled: listing_expiration_enabled
           }
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

    render body: nil, status: 200
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
