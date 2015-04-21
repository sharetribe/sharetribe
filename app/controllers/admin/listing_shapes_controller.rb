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

  Translation = EntityUtils.define_builder(
    [:locale, :string, :mandatory],
    [:value, :string, :mandatory]
  )

  Unit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :mandatory],
    [:label, :string, :optional]
  )

  ListingShapeFormEntity = EntityUtils.define_builder(
    [:name, collection: Translation],
    [:action_button_label, collection: Translation],
    [:shipping_enabled, transform_with: CHECKBOX],
    [:price_enabled, transform_with: CHECKBOX],
    [:online_payments, transform_with: CHECKBOX],
    [:units, collection: Unit],
    [:template, :to_symbol]
  )

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
    process = template[:process]

    unless template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    processed_form = parse_and_process_form(params, processes, template, process)

    unless processed_form.success
      flash[:error] = shape_result.error_msg
      return render_edit(shape, @current_community.id, available_locales())
    end

    processed_data = processed_form.data
    shape_form = processed_data[:shape_form]
    transaction_process_id = processed_data[:transaction_process_id]

    create_result = create_translations(@current_community.id, shape_form).and_then { |translations|
      name_tr_key, action_button_tr_key = translations.map { |t| t[:translation_key] }
      name_translation = translations.first[:translations]
      basename = name_translation.find { |t| t[:locale] == @current_community.default_locale } || name_translations.first

      create_shape(@current_community.id, name_tr_key, action_button_tr_key, basename[:translation], transaction_process_id, shape_form)
    }

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
    process = processes.find { |p| p[:id] == shape[:transaction_process_id] }
    return redirect_to error_not_found_path if shape.nil?

    processed_form = parse_and_process_form(params, processes, shape, process)

    unless processed_form.success
      flash[:error] = shape_result.error_msg
      return render_edit(shape, @current_community.id, available_locales())
    end

    processed_data = processed_form.data
    shape_form = processed_data[:shape_form]
    transaction_process_id = processed_data[:transaction_process_id]

    update_result = update_translations(@current_community.id, shape, shape_form).and_then {
      update_shape(@current_community.id, params[:id], transaction_process_id, shape_form)
    }

    if update_result[:success]
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: translate(shape[:name_tr_key]))
      return redirect_to admin_listing_shapes_path
    else
      flash[:error] = t("admin.listing_shapes.edit.update_failure")
      render("edit", locals: view_locals(shape, process, nil, process_info, available_locales()))
    end
  end

  private

  # shape_form -> [shape, process]
  def to_shape(shape_form)
  end

  # [shape, process] -> shape_form
  def to_shape_form(shape, process, template, available_locs)
    shape[:name] = make_translations(shape[:name_tr_key], available_locs)
    shape[:action_button_label] = make_translations(shape[:action_button_tr_key], available_locs)
    shape[:units] = expand_units(shape[:units])
    shape[:online_payments] = process[:process] == :preauthorize if process[:process]
    shape[:template] = template

    ListingShapeFormEntity.call(shape)
  end

  def parse_and_process_form(params, processes, shape_defaults, process_defaults)
    parse_params(params)
      .and_then { |shape_form|
        process_info = ListingShapeProcessViewUtils.process_info(processes)
        shape_form = ListingShapeProcessViewUtils.process_shape(shape_form, process_info, shape_defaults)
        transaction_process_id = select_process(shape_form, processes, process_defaults)

        Result::Success.new(shape_form: shape_form, transaction_process_id: transaction_process_id)
      }
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

  def parse_params(params)
    form_params = HashUtils.symbolize_keys(params)
    form_params[:name] = params[:name].map { |locale, translation|
      {locale: locale, value: translation}
    }

    form_params[:action_button_label] = form_params[:action_button_label].map { |locale, translation|
      {locale: locale, value: translation}
    }

    form_params[:units] = parse_units(form_params[:units])

    form_params = ListingShapeFormEntity.validate(form_params)
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

  def make_translations(tr_key, locales)
    locales.map { |(loc_name, loc_key)|
      {locale: loc_key, value: t(tr_key, locale: loc_key)}
    }

  end

  def update_translations(community_id, shape, shape_form)
    tr_groups = TranslationServiceHelper.to_per_key_translations({
      shape[:name_tr_key] => shape_form[:name],
      shape[:action_button_tr_key] => shape_form[:action_button_label]})

    translations_api.translations.create(community_id, tr_groups)
  end

  def create_translations(community_id, shape)
    tr_groups = [
      {translations: shape[:name].map { |t| {locale: t[:locale], translation: t[:value]} }},
      {translations: shape[:action_button_label].map { |t| {locale: t[:locale], translation: t[:value]} }}
    ]

    translations_api.translations.create(community_id, tr_groups)
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

  def create_shape(community_id, name_tr_key, action_button_tr_key, basename, transaction_process_id, shape)
    listing_api.shapes.create(
      community_id: community_id,
      opts: {
        transaction_process_id: transaction_process_id,
        name_tr_key: name_tr_key,
        action_button_tr_key: action_button_tr_key,
        shipping_enabled: shape[:shipping_enabled],
        price_enabled: shape[:price_enabled],
        units: shape[:units].map { |u| add_quantity_selector(u) },
        basename: basename
      }
    )
  end

  def update_shape(community_id, listing_shape_id, transaction_process_id, shape)
    listing_api.shapes.update(
      community_id: community_id,
      listing_shape_id: listing_shape_id,
      opts: {
        transaction_process_id: transaction_process_id,
        shipping_enabled: shape[:shipping_enabled],
        price_enabled: shape[:price_enabled],
        units: shape[:units].map { |u| add_quantity_selector(u) }
      }
    )
  end

  def add_quantity_selector(unit)
    unit.merge(quantity_selector: unit[:type] == :day ? :day : :number)
  end


  def listing_api
    ListingService::API::Api
  end
end
