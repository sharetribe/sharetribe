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

  TransactionProcess = EntityUtils.define_builder(
    [:id, :fixnum],
    [:community_id, :fixnum],
    [:author_is_seller, :to_bool, :mandatory],
    [:process, :to_symbol, one_of: [:none, :preauthorize, :postpay]])

  Unit = EntityUtils.define_builder(
    [:type, :to_symbol, one_of: [:custom, :piece, :hour, :day, :night, :week, :month]],
    [:translation_key, :string, :optional],
    [:quantity_selector, :to_symbol, one_of: ["".to_sym, :none, :number, :day]] # in the future include :hour, :week:, :night ,:month etc.
  )

  ExtendedShape = EntityUtils.define_builder(
    [:id, :fixnum],
    [:community_id, :fixnum],

    [:name_tr_key, :string, :mandatory],
    [:name, :mandatory, validate_with: FORM_TRANSLATION],
    [:action_button_tr_key, :string, :mandatory],
    [:action_button_label, :mandatory, validate_with: FORM_TRANSLATION],

    [:shipping_enabled, :bool, :mandatory],
    [:price_enabled, :bool, :mandatory],

    [:online_payments, :to_bool],
    [:transaction_process_id, :fixnum],
    [:transaction_process, :hash], # FIXME Use nested Entity TransactionProcess, but there's a bug: crashes if nill
    [:units, :mandatory, collection: Unit],
    [:sort_priority, :fixnum, default: 0],
    [:basename, :string],
    [:template, :to_symbol]
  )

  FormUnit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :mandatory],
    [:label, :string, :optional]
  )

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
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_summary)

    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             templates: templates,
             listing_shapes: all_shapes(@current_community.id)})
  end

  def new
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_summary)
    template = ListingShapeProcessViewUtils.find_template(params[:template], templates, process_summary)
    shape_template = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(template[:shape], process_summary)

    unless shape_template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    shape_template = TranslationServiceHelper.tr_keys_to_form_values(
      entity: shape_template,
      locales: available_locales.map { |_, locale| locale },
      tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP)

    extended_shape_template = ExtendedShape.call(shape_template)

    render("new", locals: extended_view_locals(shape_template, process_summary, available_locales()))
  end

  def edit
    extended_shape_res = ExtendedShapeService.new(processes).get(
      community_id: @current_community.id,
      listing_shape_id: params[:id],
      locales: available_locales.map { |_, locale| locale }
    )

    extended_shape = extended_shape_res.data

    return redirect_to error_not_found_path if extended_shape.nil?

    sanitized_shape = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(extended_shape, process_summary)

    render("edit", locals: extended_view_locals(sanitized_shape, process_summary, available_locales()))
  end

  def create
    templates = ListingShapeProcessViewUtils.available_templates(ListingShapeTemplates.all, process_summary)
    template = ListingShapeProcessViewUtils.find_template(params[:template], templates, process_summary)
    shape_template = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(template[:shape], process_summary)

    unless shape_template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    shape_template = TranslationServiceHelper.tr_keys_to_form_values(
      entity: shape_template,
      locales: available_locales.map { |_, locale| locale },
      tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP)

    extended_shape = form_to_extended(params, shape_template, @current_community.default_locale)

    sanitized_shape = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(extended_shape, process_summary)

    create_result = ListingShapeProcessViewUtils::ShapeSanitizer.validate(sanitized_shape, processes).and_then { |extended_shape|
      ExtendedShapeService.new(processes).create(community_id: @current_community.id, opts: extended_shape)
    }

    if create_result.success
      flash[:notice] = t("admin.listing_shapes.new.create_success", shape: translate_extended_shape(sanitized_shape))
      redirect_to action: :index
    else
      flash[:error] = t("admin.listing_shapes.new.create_failure", error_msg: create_result.error_msg)
      render("new", locals: extended_view_locals(sanitized_shape, process_summary, available_locales()))
    end

  end

  def update
    extended_shape_service = ExtendedShapeService.new(processes)

    old_extended_shape = extended_shape_service.get(
      community_id: @current_community.id,
      listing_shape_id: params[:id],
      locales: available_locales.map { |_, locale| locale }
    )

    return redirect_to error_not_found_path unless old_extended_shape.success

    sanitized_old_shape = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(old_extended_shape.data, process_summary)

    extended_shape = form_to_extended(params, sanitized_old_shape, @current_community.default_locale)

    sanitized_shape = ListingShapeProcessViewUtils::ShapeSanitizer.sanitize(extended_shape, process_summary)

    update_result = ListingShapeProcessViewUtils::ShapeSanitizer.validate(sanitized_shape, processes).and_then { |extended_shape|
      extended_shape_service.update(
        community_id: @current_community.id,
        listing_shape_id: extended_shape[:id],
        opts: extended_shape)
    }

    if update_result.success
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: translate_extended_shape(sanitized_shape))
      return redirect_to admin_listing_shapes_path
    else
      flash[:error] = t("admin.listing_shapes.edit.update_failure", error_msg: update_result.error_msg)
      render("edit", locals: extended_view_locals(sanitized_shape, process_summary, available_locales()))
    end
  end

  private

  def translate_extended_shape(shape)
    shape[:name].find { |(locale, translation)|
      locale.to_s == I18n.locale.to_s
    }.second
  end

  def extended_to_form(shape, process_summary)
    extended_shape = ExtendedShape.call(shape)

    Form.call(
      ExtendedShape.call(extended_shape).merge(
        units: expand_units(extended_shape[:units]),
        online_payments: process_to_online_payments(shape, process_summary)
    ))
  end

  def process_to_online_payments(shape, process_summary)
    online_payments_available = process_summary[:preauthorize_available] || process_summary[:postpay_available]

    if online_payments_available
      existing_process = Maybe(shape)[:transaction_process][:process].or_else(nil)

      from_template = shape[:online_payments]
      from_process = existing_process == :preauthorize || existing_process == :postpay

      from_process || from_template
    else
      false
    end
  end

  def form_to_extended(params, shape_or_template, default_locale)
    form_params = HashUtils.symbolize_keys(params)
    form = Form.call(form_params.merge(
      units: parse_units(params[:units])
    ))

    # TODO This doesn't feel right
    form[:transaction_process] = { process: form[:online_payments] ? :preauthorize : :none }
    form[:units] = form[:units].map { |u| add_quantity_selector(u) }
    form[:basename] = form[:name][default_locale]

    ExtendedShape.call(merge_form_and_shape(form, shape_or_template))
  end

  def merge_form_and_shape(form, extended_shape)
    extended_shape.deep_merge(form)
  end

  def extended_view_locals(extended_shape, process_summary, available_locs)
    { name_tr_key: extended_shape[:name_tr_key],
      id: extended_shape[:id],
      selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: ListingShapeProcessViewUtils.uneditable_fields(extended_shape[:transaction_process], process_summary),
      shape: extended_to_form(extended_shape, process_summary),
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
    listing_api.shapes.get(community_id: community_id)
      .maybe()
      .or_else([])
  end

  def process_summary
    @process_summary ||= ListingShapeProcessViewUtils.process_info(processes)
  end

  def processes
    @processes ||= TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]
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
  class ExtendedShapeService

    def initialize(processes)
      @processes = processes
    end

    def get(community_id:, listing_shape_id:, locales:)
      extended_shape = listing_api.shapes.get(community_id: community_id, listing_shape_id: listing_shape_id).and_then { |shape|
        process = @processes.find { |p| p[:id] == shape[:transaction_process_id] }

        raise ArgumentError.new("Can not find process with id: #{shape[:transaction_process_id]}") if process.nil?

        shape_with_process = shape.merge(transaction_process: process)

        shape_with_translations = TranslationServiceHelper.tr_keys_to_form_values(
          entity: shape_with_process,
          locales: locales,
          tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP)

        Result::Success.new(ExtendedShape.call(shape_with_translations))
      }
    end

    def update(community_id:, listing_shape_id:, opts:)
      extended_shape = ExtendedShape.call(opts)

      with_process = extended_shape.merge(
        transaction_process_id: select_process(extended_shape, @processes))

      # TODO Transaction
      with_translations = TranslationServiceHelper.form_values_to_tr_keys!(
        target: with_process,
        form: with_process,
        tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP,
        community_id: community_id,
      )

      listing_api.shapes.update(
        community_id: community_id,
        listing_shape_id: listing_shape_id,
        opts: with_translations
      )
    end

    def create(community_id:, opts:)
      extended_shape = ExtendedShape.call(opts)

      with_process = extended_shape.merge(
        transaction_process_id: select_process(extended_shape, @processes))

      # TODO Transaction
      with_translations = TranslationServiceHelper.form_values_to_tr_keys!(
        target: with_process,
        form: with_process,
        tr_key_prop_form_name_map: TR_KEY_PROP_FORM_NAME_MAP,
        community_id: community_id,
        override: true
      )

      listing_api.shapes.create(
        community_id: community_id,
        opts: with_translations
      )
    end

    private

    def listing_api
      ListingService::API::Api
    end

    def select_process(extended_shape, processes)
      process_find_opts = extended_shape[:transaction_process].slice(:author_is_seller, :process)

      Maybe(
        processes.find { |p|
          p.slice(*process_find_opts.keys) == process_find_opts
        })[:id].or_else(nil).tap { |p|
          raise ArgumentError.new("Can not find suitable transaction process for #{process_find_opts}") if p.nil?
      }
    end

  end
end
