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
    processes = TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]

    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             templates: templates(processes),
             listing_shapes: all_shapes(@current_community.id)})
  end

  def new
    processes = TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]

    unless valid_template?(params[:template], processes)
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    template = templates(processes).find { |tmpl| tmpl[:key] == params[:template].to_sym }
    render("new", locals: new_view_locals(template, available_locales()))
  end

  def edit
    shape = get_shape(@current_community.id, params[:id])
    return redirect_to error_not_found_path if shape.nil?

    render("edit", locals: edit_view_locals(shape, available_locales()))
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
      render("edit", locals: edit_view_locals(shape, available_locales()))
    end
  end


  private

  def valid_template?(template_key, processes)
    key = template_key.to_sym
    templates(processes).any? { |tmpl| tmpl[:key] == key }
  end

  def templates(transaction_processes)
    request_process_available = transaction_processes.any? { |tp| tp[:author_is_seller] == false }
    preauthorize_process_available = transaction_processes.any? { |tp| tp[:process] == :preauthorize }

    template_defaults.reject { |tmpl|
      tmpl[:key] == :requesting && !request_process_available
    }.map { |tmpl|
      tmpl[:price_enabled]          = {default: tmpl[:price_enabled], can_change: true}
      tmpl[:shipping_enabled]       = {default: tmpl[:shipping_enabled], can_change: preauthorize_process_available}
      tmpl[:online_payment_enabled] = {default: tmpl[:online_payment_enabled], can_change: preauthorize_process_available}
      tmpl[:author_is_seller]       = {default: tmpl[:author_is_seller], can_change: false}
      tmpl
    }
  end

  def template_defaults
    [
      {
        label: t("admin.listing_shapes.templates.selling_products"),
        key: :selling_products,
        name_tr_key: "admin.transaction_types.sell",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.sell",
        price_enabled: true,
        shipping_enabled: true,
        online_payments: true,
        author_is_seller: true,
        units: []
      },
      {
        label: t("admin.listing_shapes.templates.renting_products"),
        key: :renting_products,
        name_tr_key: "admin.transaction_types.rent",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.rent",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        author_is_seller: true,
        units: [{type: :day}, {type: :week}, {type: :month}]
      },
      {
        label: t("admin.listing_shapes.templates.offering_services"),
        key: :offering_services,
        name_tr_key: "admin.transaction_types.service",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: true,
        shipping_enabled: false,
        online_payments: true,
        author_is_seller: true,
        units: [{type: :hour}]
      },
      {
        label: t("admin.listing_shapes.templates.giving_things_away"),
        key: :giving_things_away,
        name_tr_key: "admin.transaction_types.give",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.offer",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      },
      {
        label: t("admin.listing_shapes.templates.requesting"),
        key: :requesting,
        name_tr_key: "admin.transaction_types.request",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.request",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: false,
        units: []
      },
      {
        label: t("admin.listing_shapes.templates.announcement"),
        key:  :announcement,
        name_tr_key: "admin.transaction_types.inquiry",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.inquiry",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      },
      {
        label: t("admin.listing_shapes.templates.custom"),
        key: :custom,
        name_tr_key: "admin.transaction_types.custom",
        action_button_tr_key: "admin.transaction_types.default_action_button_labels.custom",
        price_enabled: false,
        shipping_enabled: false,
        online_payments: false,
        author_is_seller: true,
        units: []
      }
    ]
  end

  def edit_view_locals(shape, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      shape: shape,
      shape_form: to_form_data(shape, available_locs),
      locale_name_mapping: available_locs.map { |name, l| [l, name]}.to_h  }
  end

  def new_view_locals(shape, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      shape: shape,
      shape_form: to_form_data(shape, available_locs),
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

  def to_form_data(shape, available_locs)
    action_button_translations = available_locs.map { |(loc_name, loc_key)|
      [loc_key, t(shape[:action_button_tr_key], locale: loc_key)]
    }.to_h


    name_translations = available_locs.map { |(loc_name, loc_key)|
      [loc_key, t(shape[:name_tr_key], locale: loc_key)]
    }.to_h

    shape_units = shape[:units].map { |t| t[:type] }.to_set
    units = ListingShapeHelper.predefined_unit_types
      .map { |t| {type: t, enabled: shape_units.include?(t), label: t("admin.listing_shapes.units.#{t}")} }
      .concat(shape[:units]
              .select { |unit| unit[:type] == :custom }
              .map { |unit| {type: unit[:type], enabled: true, label: translate(unit[:translation_key])} })

    ListingShapeForm.new(name: name_translations,
                         action_button_label: action_button_translations,
                         shipping_enabled: shape[:shipping_enabled],
                         units: units)
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
