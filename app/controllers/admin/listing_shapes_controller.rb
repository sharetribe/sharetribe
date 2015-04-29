class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  ensure_feature_enabled :shape_ui

  before_filter :ensure_no_braintree

  LISTING_SHAPES_NAVI_LINK = "listing_shapes"

  Form = ListingShapeDataTypes::Form
  TR_MAP = ListingShapeDataTypes::TR_KEY_PROP_FORM_NAME_MAP

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
    template = ListingShapeTemplates.new(process_summary).find(params[:template], available_locales.map(&:second))

    unless template
      flash[:error] = "Invalid template: #{params[:template]}"
      return redirect_to action: :index
    end

    render("new", locals: new_view_locals(template, process_summary, available_locales()))
  end

  def edit
    form = ShapeService.new(processes).get(
      community_id: @current_community.id,
      listing_shape_id: params[:id],
      locales: available_locales.map { |_, locale| locale }
    ).data

    return redirect_to error_not_found_path if form.nil?

    render("edit", locals: edit_view_locals(params[:id], pick_translation(form[:name]), form, process_summary, available_locales()))
  end

  def create
    params_form = filter_uneditable_fields(params_to_form(params), process_summary)

    create_result = validate_form(params_form).and_then { |form|
      ShapeService.new(processes).create(
        community_id: @current_community.id,
        default_locale: @current_community.default_locale,
        opts: form
      )
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
      ShapeService.new(processes).update(
        community_id: @current_community.id,
        listing_shape_id: params[:id],
        opts: form
      )
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
    uneditable_keys = uneditable_fields(process_summary).select { |_, uneditable| uneditable }.keys
    form.except(*uneditable_keys)
  end

  def uneditable_fields(process_summary)
    {
      shipping_enabled: !process_summary[:preauthorize_available],
      online_payments: !process_summary[:preauthorize_available]
    }
  end

  def new_view_locals(form, process_summary, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: uneditable_fields(process_summary),
      shape: expand_form_units(form),
      locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h
    }
  end

  def edit_view_locals(id, name_tr_key, form, process_summary, available_locs)
    { name_tr_key: name_tr_key,
      id: id,
      selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: uneditable_fields(process_summary),
      shape: expand_form_units(form),
      locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h
    }
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

  def expand_form_units(form)
    Form.call(form.merge(
      units: expand_units(form[:units]),
    ))
  end

  def params_to_form(params)
    form_params = HashUtils.symbolize_keys(params)
    Form.call(form_params.merge(
      units: parse_units(form_params[:units])
             )).tap { |form|
    }
  end

  def pick_translation(translations)
    translations.find { |(locale, translation)|
      locale.to_s == I18n.locale.to_s
    }.second
  end

  # Take units from shape and add predefined units
  def expand_units(shape_units)
    shape_units_set = shape_units.map { |t| t[:type] }.to_set

    ListingShapeHelper.predefined_unit_types
      .map { |t| {type: t, enabled: shape_units_set.include?(t), label: I18n.t("admin.listing_shapes.units.#{t}")} }
      .concat(shape_units
              .select { |unit| unit[:type] == :custom }
              .map { |unit| {type: unit[:type], enabled: true, label: translate(unit[:translation_key])} }) # TODO Change translate
  end

  def parse_units(selected_units)
    (selected_units || []).map { |type, _| {type: type.to_sym, enabled: true}}
  end

  def ensure_no_braintree
    if BraintreePaymentGateway.exists?(community_id: @current_community.id)
      flash[:error] = "Not available for Braintree"
      redirect_to edit_details_admin_community_path(@current_community.id)
    end
  end
end
