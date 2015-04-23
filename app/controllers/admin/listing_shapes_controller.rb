class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  ensure_feature_enabled :shape_ui

  LISTING_SHAPES_NAVI_LINK = "listing_shapes"

  # true -> true # idempotent
  # false -> false # idempotent
  # nil -> false
  # anything else -> true
  CHECKBOX = -> (value) {
    if value == true || value == false
      value
    else
      !value.nil?
    end
  }

  FORM_TRANSLATION = ->(h) {
    unless h.all? { |(k, v)| k.is_a?(String) && v.is_a?(String) }
      {code: :form_translation_hash_format, msg: "Value must be a hash of { locale => translations }" }
    end
  }

  Unit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :mandatory],
    [:label, :string, :optional]
  )

  TransactionProcess = EntityUtils.define_builder(
    [:id, :fixnum],
    [:community_id, :fixnum],
    [:author_is_seller, :to_bool, :mandatory],
    [:process, :to_symbol, one_of: [:none, :preauthorize, :postpay]])

  ExtendedShape = EntityUtils.define_builder(
    [:id, :fixnum],
    [:community_id, :fixnum, :mandatory],

    [:name_tr_key, :string, :mandatory],
    [:name, :mandatory, validate_with: FORM_TRANSLATION],
    [:action_button_tr_key, :string, :mandatory],
    [:action_button_label, :mandatory, validate_with: FORM_TRANSLATION],

    [:shipping_enabled, :bool, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:transaction_process_id, :fixnum, :mandatory],
    [:transaction_process, entity: TransactionProcess],
    [:units, :array, :mandatory],
    [:sort_priority, :fixnum, default: 0]
  )

  Form = EntityUtils.define_builder(
    [:name, :hash, :mandatory],
    [:action_button_label, :hash, :mandatory],
    [:shipping_enabled, transform_with: CHECKBOX],
    [:price_enabled, transform_with: CHECKBOX],
    [:online_payments, transform_with: CHECKBOX],
    [:units, collection: Unit],
    [:template, :to_symbol]
  )

  TR_KEY_PROP_FORM_NAME_MAP = {
    name_tr_key: :name,
    action_button_tr_key: :action_button_label
  }

  def index
    process_info = get_process_info(@current_community.id)
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_info)

    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             templates: templates,
             listing_shapes: all_shapes(@current_community.id)})
  end

  def new
    process_info = get_process_info(@current_community.id)
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_info)
    template = ListingShapeProcessViewUtils.find_template(params[:template], templates, process_info)
    shape = template[:shape]
    process = template[:process]

    unless template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    render("new", locals: view_locals(shape, process, template[:template], process_info, available_locales()))
  end

  def edit
    processes = get_processes(@current_community.id)
    process_info = ListingShapeProcessViewUtils.process_info(processes)
    shape = get_shape(@current_community.id, params[:id])
    process = processes.find { |p| p[:id] == shape[:transaction_process_id] }

    return redirect_to error_not_found_path if shape.nil?

    render("edit", locals: view_locals(shape, process, nil, process_info, available_locales()))
  end

  def create
    processes = get_processes(@current_community.id)
    process_info = ListingShapeProcessViewUtils.process_info(processes)
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_info)
    template = ListingShapeProcessViewUtils.find_template(params[:template], templates, process_info)
    shape = template[:shape]
    process_requirements = template[:process]

    unless template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    new_shape = form_to_shape!(params, process_info, processes, process_requirements, @current_community.id, @current_community.default_locale, shape, true)

    create_result = create_shape(@current_community.id, new_shape)

    if create_result.success
      flash[:message] = t("admin.listing_shapes.new.create_success")
      redirect_to action: :index
    else
      flash[:error] = t("admin.listing_shapes.new.create_failure")
      # TODO RENDER SOMETHING
    end

  end

  def update
    processes = get_processes(@current_community.id)
    process_info = ListingShapeProcessViewUtils.process_info(processes)
    shape = get_shape(@current_community.id, params[:id])
    process_requirements = processes.find { |p| p[:id] == shape[:transaction_process_id] }
    return redirect_to error_not_found_path if shape.nil?

    updated_shape = form_to_shape!(params, process_info, processes, process_requirements, @current_community.id, @current_community.default_locale, shape)

    update_result = update_shape(@current_community.id, params[:id], updated_shape)

    if update_result[:success]
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: translate(shape[:name_tr_key]))
      return redirect_to admin_listing_shapes_path
    else
      flash[:error] = t("admin.listing_shapes.edit.update_failure")
      render("edit", locals: view_locals(shape, process, nil, process_info, available_locales()))
    end
  end

  private

  def form_to_shape!(form_params, process_info, processes, process_requirements, community_id, default_locale, target, override = false)
    form_res = parse_form(form_params).and_then { |shape_form|
      shape_form = ListingShapeProcessViewUtils.process_shape(shape_form, process_info, target)
      transaction_process_id = select_process(shape_form, processes, process_requirements)

      Result::Success.new(shape_form.merge(transaction_process_id: transaction_process_id))
    }
    form = form_res.data

    TranslationServiceHelper.form_values_to_tr_keys!(
      target: target,
      form: form,
      tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP,
      community_id: community_id,
      override: target.nil?
    ).merge(
      transaction_process_id: form[:transaction_process_id],
      basename: form[:name][default_locale],
      units: form[:units].map { |u| add_quantity_selector(u) }
    )
  end

  # [shape, process] -> shape_form
  def to_shape_form(shape, process, template, available_locs)
    locales = available_locs.map { |name, locale| locale }

    shape = TranslationServiceHelper.tr_keys_to_form_values(
      entity: shape,
      locales: locales,
      tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP)

    shape[:units] = expand_units(shape[:units])
    shape[:online_payments] = process[:process] == :preauthorize if process[:process]
    shape[:template] = template

    Form.call(shape)
  end

  def select_process(shape, processes, process_defaults)
    process_find_opts = {
      process: shape[:online_payments] ? :preauthorize : :none,
      author_is_seller: process_defaults[:author_is_seller]
    }

    Maybe(processes.find { |p|
      p.slice(*process_find_opts.keys) == process_find_opts
    })[:id].or_else(nil).tap { |p|
      raise ArgumentError.new("Can not find suitable transaction process for #{process_find_opts}") if p.nil?
    }
  end

  def view_locals(shape, process, template_name, process_info, available_locs)
    { name_tr_key: shape[:name_tr_key],
      id: shape[:id],
      selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: ListingShapeProcessViewUtils.uneditable_fields(process_info),
      shape: to_shape_form(shape, process, template_name, available_locs),
      locale_name_mapping: available_locs.map { |name, l| [l, name]}.to_h }
  end

  def parse_form(params)
    form_params = HashUtils.symbolize_keys(params)
    form_params[:units] = parse_units(form_params[:units])
    Form.validate(form_params)
  end

  # Take units from shape and add predefined units
  def expand_units(shape_units)
    shape_units_set = shape_units.map { |t| t[:type] }.to_set

    ListingShapeHelper.predefined_unit_types
      .map { |t| {type: t, enabled: shape_units_set.include?(t), label: t("admin.listing_shapes.units.#{t}")} }
      .concat(shape_units
              .select { |unit| unit[:type] == :custom }
              .map { |unit| {type: unit[:type], enabled: true, label: translate(unit[:translation_key])} }) # TODO Change translate
  end

  def parse_units(selected_units)
    (selected_units || []).map { |type, _| {type: type.to_sym, enabled: true}}
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

  def get_process_info(community_id)
    ListingShapeProcessViewUtils.process_info(get_processes(community_id))
  end

  def get_processes(community_id)
    TransactionService::API::Api.processes.get(community_id: community_id)[:data]
  end

  def create_shape(community_id, shape)
    listing_api.shapes.create(
      community_id: community_id,
      opts: shape
    )
  end

  def update_shape(community_id, listing_shape_id, shape)
    listing_api.shapes.update(
      community_id: community_id,
      listing_shape_id: listing_shape_id,
      opts: shape
    )
  end

  def add_quantity_selector(unit)
    unit.merge(quantity_selector: unit[:type] == :day ? :day : :number)
  end

  def listing_api
    ListingService::API::Api
  end

  # A helper module that let's you reload listing shapes by community id or
  # community id and listing shape id, and gets back the shape with translations
  # and process information included
  module ExtendedShapeService
    module_function

    def get(community_id:, listing_shape_id:)
      raise NotImplementedError.new("ExtendedShapeService not implemented")
    end

    def create(community_id:, opts:)
      raise NotImplementedError.new("ExtendedShapeService not implemented")
    end

    def update(community_id:, listing_shape_id:, opts:)
      raise NotImplementedError.new("ExtendedShapeService not implemented")
    end

  end
end
