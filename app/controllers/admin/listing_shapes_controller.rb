class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  ensure_feature_enabled :shape_ui

  LISTING_SHAPES_NAVI_LINK = "listing_shapes"

  ListingShapeForm = FormUtils.define_form(
    "ListingShapeForm",
    :name,
    :action_button_label,
    :shipping_enabled,
    :units,
  ).with_validations {
    validates :name, presence: true
    validates :action_button_label, presence: true
    validates :shipping_enabled, inclusion: { in: [true, false] }
  }

  def index
    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             listing_shapes: all_shapes(@current_community.id)})
  end

  def new
    shape = new_shape_template(@current_community.id)
    render("new", locals: new_view_locals(
             shape,
             make_empty_translations(shape, available_locales()),
             available_locales()))
  end

  def edit
    shape = get_shape(@current_community.id, params[:id])
    return redirect_to error_not_found_path if shape.nil?

    render("edit", locals: edit_view_locals(shape, get_translations(shape, available_locales()), available_locales()))
  end

  def update
    shape = get_shape(@current_community.id, params[:id])
    return redirect_to error_not_found_path if shape.nil?

    shape_form = parse_params_to_form(params)
    unless shape_form.valid?
      flash[:error] = shape_form.errors.full_messages.join(", ")
      return render_edit(shape, @current_community.id, available_locales())
    end

    update_result =
      update_translations(shape, shape_form)
      .and_then { update_shape(shape, shape_form) }

    if update_result[:success]
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: translate(shape[:name_tr_key]))
      return redirect_to admin_listing_shapes_path
    else
      flash[:error] = t("admin.listing_shapes.edit.update_failure")
      render("edit", locals: edit_view_locals(shape, get_translations(shape, available_locales()), available_locales()))
    end
  end


  private

  def edit_view_locals(shape, translations, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      shape: shape,
      shape_form: to_form_data(shape, translations),
      locale_name_mapping: available_locs.map { |name, l| [l, name]}.to_h  }
  end

  def new_view_locals(shape, translations, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      shape: shape,
      shape_form: to_form_data(shape, translations),
      locale_name_mapping: available_locs.map { |name, l| [l, name]}.to_h }
  end


  def parse_params_to_form(params)
    ListingShapeForm.new(
      params
      .slice(:name, :action_button_label)
      .merge(shipping_enabled: params[:shipping_enabled] == "true")
      .merge(units: Maybe(params[:units]).or_else([]).map { |t, _| parse_unit(t) }))
  end

  def parse_unit(type)
    type_sym = type.to_sym
    selector =
      if type_sym == :day
        :day
      else
        :number
      end
    {type: type_sym, quantity_selector: selector}
  end

  def to_form_data(shape, translations)
    trs = TranslationServiceHelper.to_key_locale_hash(translations)

    shape_units = shape[:units].map { |t| t[:type] }.to_set
    units = ListingShapeHelper.predefined_unit_types
      .map { |t| {type: t, enabled: shape_units.include?(t), label: t("admin.listing_shapes.units.#{t}")} }
      .concat(shape[:units]
              .select { |unit| unit[:type] == :custom }
              .map { |unit| {type: unit[:type], enabled: true, label: translate(unit[:translation_key])} })

    ListingShapeForm.new(name: trs[shape[:name_tr_key]],
                         action_button_label: trs[shape[:action_button_tr_key]],
                         shipping_enabled: shape[:shipping_enabled],
                         units: units)
  end


  def get_translations(shape, available_locs)
    translations_api.translations.get(
      shape[:community_id],
      translation_keys: [shape[:name_tr_key], shape[:action_button_tr_key]],
      locales: available_locs.map(&:second))
      .maybe()
      .or_else([])
  end

  def make_empty_translations(shape, available_locs)
    empty_trs = available_locs.map { |_, loc| {locale: loc, translation: ""}}

    empty_trs.map { |t| t.merge({translation_key: shape[:name_tr_key]}) }
      .concat(empty_trs.map { |t| t.merge({translation_key: shape[:action_button_tr_key]}) })
  end

  def update_translations(shape, shape_form)
    tr_groups = TranslationServiceHelper.to_per_key_translations({
      shape[:name_tr_key] => shape_form.name,
      shape[:action_button_tr_key] => shape_form.action_button_label})

    translations_api.translations.create(shape[:community_id], tr_groups)
  end

  def translations_api
    TranslationService::API::Api
  end

  def new_shape_template(community_id)
    { community_id: community_id,
      price_enabled: true,
      name_tr_key: "name-key-placeholder",
      action_button_tr_key: "action-button-key-placeholder",
      shipping_enabled: false,
      units: [] }
  end

  def all_shapes(community_id)
    listing_api.shapes.get(community_id: community_id)
      .maybe()
      .or_else([])
  end

  def get_shape(community_id, listing_shape_id)
    listing_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id)
      .maybe()
      .or_else(nil)
  end

  def update_shape(shape, shape_form)
    listing_api.shapes.update(
      community_id: shape[:community_id],
      listing_shape_id: shape[:id],
      opts: {
        shipping_enabled: shape_form.shipping_enabled,
        units: shape_form.units
      }
    )
  end

  def listing_api
    ListingService::API::Api
  end
end
