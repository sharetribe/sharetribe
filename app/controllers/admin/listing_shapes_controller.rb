class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  ensure_feature_enabled :shape_ui

  before_filter :ensure_no_braintree

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
    [:type, :symbol, :mandatory]
  )

  # Shape describes the data in Templates list.
  # Also, ShapeService.get returns Shape
  # Shape can be used to construct a Form
  Shape = EntityUtils.define_builder(
    [:label, :string, :optional], # Only for predefined templates
    [:template, :symbol, :optional], # Only for predefined templates
    [:name_tr_key, :string, :mandatory],
    [:action_button_tr_key, :string, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:shipping_enabled, :bool, :mandatory],
    [:online_payments, :bool, :mandatory],
    [:units, collection: Unit]
  )

  FormUnit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :mandatory],
    [:label, :string, :optional]
  )

  # Form can be passed to view to render the form.
  # Also, form can be constructed from the params.
  # Form can be passed to ShapeService and it will handle saving it
  Form = EntityUtils.define_builder(
    [:name, :hash, :mandatory],
    [:action_button_label, :hash, :mandatory],
    [:shipping_enabled, transform_with: CHECKBOX],
    [:price_enabled, transform_with: CHECKBOX],
    [:online_payments, transform_with: CHECKBOX],
    [:units, default: [], collection: FormUnit],
    [:template, :to_symbol]
  )

  TR_KEY_PROP_FORM_NAME_MAP = {
    name_tr_key: :name,
    action_button_tr_key: :action_button_label
  }

  def index
    category_count = @current_community.categories.count
    template_label_key_list = ListingShapeTemplates.new(process_summary).label_key_list

    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             templates: template_label_key_list,
             category_count: category_count,
             listing_shapes: all_shapes(@current_community.id)})
  end

  def new
    template = ListingShapeTemplates.new(process_summary).find(params[:template])

    unless template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    form = shape_to_form(template, available_locales.map(&:second))

    render("new", locals: new_view_locals(form, process_summary, available_locales()))
  end

  def edit
    shape = ShapeService.new(processes).get(
      community_id: @current_community.id,
      listing_shape_id: params[:id],
      locales: available_locales.map { |_, locale| locale }
    ).data

    form = shape_to_form(shape, available_locales.map(&:second))

    return redirect_to error_not_found_path if form.nil?

    render("edit", locals: edit_view_locals(params[:id], shape[:name_tr_key], form, process_summary, available_locales()))
  end

  def create
    params_form = filter_uneditable_fields(params_to_form(params), process_summary)

    create_result = validate_form(params_form).and_then { |form|
      ShapeService.new(processes).create(community_id: @current_community.id, default_locale: @current_community.default_locale, opts: form)
    }

    if create_result.success
      flash[:notice] = t("admin.listing_shapes.new.create_success", shape: pick_translation(params_form[:name]))
      redirect_to action: :index
    else
      flash[:error] = t("admin.listing_shapes.new.create_failure", error_msg: create_result.error_msg)
      render("new", locals: new_view_locals(params_form, process_summary, available_locales()))
    end

  end

  def update
    params_form = filter_uneditable_fields(params_to_form(params), process_summary)

    update_result = validate_form(params_form).and_then { |form|
      ShapeService.new(processes).update(community_id: @current_community.id, listing_shape_id: params[:id], opts: form)
    }

    if update_result.success
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: pick_translation(params_form[:name]))
      return redirect_to admin_listing_shapes_path
    else
      flash[:error] = t("admin.listing_shapes.edit.update_failure", error_msg: update_result.error_msg)
      render("edit", locals: edit_view_locals(params[:id], form[:name_tr_key], form, process_summary, available_locales()))
    end
  end

  private

  def filter_uneditable_fields(form, process_summary)
    form = Form.call(form)

    uneditable_keys = uneditable_fields(process_summary).select { |_, uneditable| uneditable }.keys

    form.except(*uneditable_keys)
  end

  def uneditable_fields(process_summary)
    {
      shipping_enabled: !process_summary[:preauthorize_available],
      online_payments: !process_summary[:preauthorize_available]
    }
  end

  def validate_form(form)
    form = Form.call(form)

    errors = []

    if form[:shipping_enabled] && !form[:online_payments]
      errors << "Shipping can not be enabled without online payments"
    end

    if form[:online_payments] && !form[:price_enabled]
      errors << "Online payments can not be enabled without price"
    end

    if form[:units].present? && !form[:price_enabled]
      errors << "Price units can not be used without price field"
    end

    if errors.empty?
      Result::Success.new(form)
    else
      Result::Error.new(errors.join(", "))
    end
  end

  def shape_to_form(template, locales)
    template = Shape.call(template)

    template_with_translations = TranslationServiceHelper.tr_keys_to_form_values(
      entity: template,
      locales: locales,
      tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP)

    Form.call(template_with_translations.merge(
      units: expand_units(template_with_translations[:units]),
    ))
  end

  def params_to_form(params)
    form_params = HashUtils.symbolize_keys(params)
    Form.call(form_params.merge(
      units: parse_units(form_params[:units])
    ))
  end

  def pick_translation(translations)
    translations.find { |(locale, translation)|
      locale.to_s == I18n.locale.to_s
    }.second
  end

  def new_view_locals(form, process_summary, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: uneditable_fields(process_summary),
      shape: form,
      locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h
    }
  end

  def edit_view_locals(id, name_tr_key, form, process_summary, available_locs)
    { name_tr_key: name_tr_key,
      id: id,
      selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: uneditable_fields(process_summary),
      shape: form,
      locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h
    }
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

  def all_shapes(community_id)
    ListingService::API::Api.shapes.get(community_id: community_id)
      .maybe()
      .or_else([])
  end

  def process_summary
    @process_summary ||= processes.reduce({}) { |info, process|
      info[:preauthorize_available] = true if process[:process] == :preauthorize
      info
    }
  end

  def processes
    @processes ||= TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]
  end

  # A helper module that let's you reload listing shapes by community id or
  # community id and listing shape id, and gets back the shape with translations
  # and process information included
  class ShapeService

    def initialize(processes)
      @processes = processes
    end

    def get(community_id:, listing_shape_id:, locales:)
      extended_shape = listing_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id).and_then { |shape|
        process = @processes.find { |p| p[:id] == shape[:transaction_process_id] }

        raise ArgumentError.new("Can not find process with id: #{shape[:transaction_process_id]}") if process.nil?

        shape_with_process = shape.merge(online_payments: process[:process] == :preauthorize) # TODO More sophisticated?

        Result::Success.new(Shape.call(shape_with_process))
      }
    end

    def update(community_id:, listing_shape_id:, opts:)
      form_opts = Form.call(opts)

      with_translations = TranslationServiceHelper.form_values_to_tr_keys!(
        target: form_opts,
        form: form_opts,
        tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP,
        community_id: community_id,
        override: false
      )

      with_units = with_translations.merge(
        units: with_translations[:units].map { |u| add_quantity_selector(u) }
      )

      with_process = with_units.merge(
        transaction_process_id: select_process(with_units[:online_payments], @processes))

      listing_api.shapes.update(
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        opts: with_process
      )
    end

    def create(community_id:, default_locale:, opts:)
      form_opts = Form.call(opts)

      with_translations = TranslationServiceHelper.form_values_to_tr_keys!(
        target: form_opts,
        form: form_opts,
        tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP,
        community_id: community_id,
        override: true
      )

      with_basename = with_translations.merge(
        basename: with_translations[:name][default_locale]
      )

      with_units = with_basename.merge(
        units: with_basename[:units].map { |u| add_quantity_selector(u) }
      )

      with_process = with_units.merge(
        transaction_process_id: select_process(with_units[:online_payments], @processes))

      listing_api.shapes.create(
        community_id: community_id,
        opts: with_process
      )
    end

    private

    def listing_api
      ListingService::API::Api
    end

    def add_quantity_selector(unit)
      unit.merge(quantity_selector: unit[:type] == :day ? :day : :number)
    end

    def select_process(online_payments, processes)
      # TODO Maybe more sophisticated version
      author_is_seller = true
      process = online_payments ? :preauthorize : :none

      selected = processes.find { |p| p[:author_is_seller] == author_is_seller && p[:process] == process }

      raise ArugmentError.new("Can not find suitable process") if selected.nil?

      selected[:id]
    end

  end

  def ensure_no_braintree
    if BraintreePaymentGateway.exists?(community_id: @current_community.id)
      flash[:error] = "Not available for Braintree"
      redirect_to edit_details_admin_community_path(@current_community.id)
    end
  end
end
