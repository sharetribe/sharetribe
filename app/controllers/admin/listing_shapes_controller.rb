class Admin::ListingShapesController < ApplicationController
  before_filter :ensure_is_admin

  before_filter :ensure_no_braintree_or_checkout
  before_filter :set_url_name

  LISTING_SHAPES_NAVI_LINK = "listing_shapes"

  Shape = ListingShapeDataTypes::Shape

  def index
    category_count = @current_community.categories.count
    template_label_key_list = ListingShapeTemplates.new(process_summary).label_key_list

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      getting_started_guide_admin_community_path(@current_community),
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    render("index",
           locals: {
             selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
             templates: template_label_key_list,
             display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
             knowledge_base_url: APP_CONFIG.knowledge_base_url,
             category_count: category_count,
             listing_shapes: all_shapes(community_id: @current_community.id, include_categories: true)
             }.merge(onboarding_popup_locals))
  end

  def new
    template = ListingShapeTemplates.new(process_summary).find(params[:template], available_locales.map(&:second))

    unless template
      return redirect_to action: :index
    end

    render_new_form(template, process_summary, available_locales())
  end

  def edit
    shape = ShapeService.new(processes).get(
      community_id: @current_community.id,
      name: params[:url_name],
      locales: available_locales.map { |_, locale| locale }
    ).data

    return redirect_to error_not_found_path if shape.nil?

    render_edit_form(params[:url_name], shape, process_summary, available_locales())
  end

  def create
    shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)

    create_result = validate_shape(shape).and_then { |s|
      ShapeService.new(processes).create(
        community_id: @current_community.id,
        default_locale: @current_community.default_locale,
        opts: s
      )
    }

    if create_result.success
      flash[:notice] = t("admin.listing_shapes.new.create_success", shape: pick_translation(shape[:name]))
      redirect_to action: :index
    else
      flash.now[:error] = t("admin.listing_shapes.new.create_failure", error_msg: create_result.error_msg)
      render_new_form(shape, process_summary, available_locales())
    end

  end

  def update
    shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)

    update_result = validate_shape(shape).and_then { |s|
      ShapeService.new(processes).update(
        community_id: @current_community.id,
        name: params[:url_name],
        opts: s
      )
    }

    if update_result.success
      flash[:notice] = t("admin.listing_shapes.edit.update_success", shape: pick_translation(shape[:name]))

      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:listing_shape_updated, [update_result.data])
      if state_changed
        report_to_gtm([{event: "km_record", km_event: "Onboarding payments setup"},
                       {event: "km_record", km_event: "Onboarding payment disabled"}])

        with_feature(:onboarding_redesign_v1) do
          flash[:show_onboarding_popup] = true
        end
      end
      return redirect_to admin_listing_shapes_path
    else
      flash.now[:error] = t("admin.listing_shapes.edit.update_failure", error_msg: update_result.error_msg)
      return render_edit_form(params[:url_name], shape, process_summary, available_locales())
    end
  end

  def order
    ordered_ids = params[:order].map(&:to_i)

    shapes = all_shapes(community_id: @current_community.id, include_categories: false)

    old_shape_order_id_map = shapes.map { |s|
      {
        id: s[:id],
        sort_priority: s[:sort_priority]
      }
    }

    old_shape_order = old_shape_order_id_map.map { |s| s[:sort_priority] }

    distinguisable_order = old_shape_order.reduce([old_shape_order.first]) { |memo, x|
      last = memo.last
      memo << if x <= last
        last + 1
      else
        x
      end
    }

    new_shape_order_id_map = ordered_ids.zip(distinguisable_order).map { |id, sort|
      {
        id: id,
        sort_priority: sort
      }
    }

    diff = ArrayUtils.diff_by_key(old_shape_order_id_map, new_shape_order_id_map, :id)

    diff.select { |d| d[:action] == :changed }.each { |d|
      opts = { sort_priority: d[:value][:sort_priority]}
      listing_api.shapes.update(community_id: @current_community.id, listing_shape_id: d[:value][:id], opts: opts)
    }

    render nothing: true, status: 200
  end

  def close_listings
    listing_api.shapes.get(community_id: @current_community.id, name: params[:url_name]).and_then { |shape|
      listing_api.listings.update_all(community_id: @current_community.id, query: { listing_shape_id: shape[:id] }, opts: { open: false })
    }.on_success {
      flash[:notice] = t("admin.listing_shapes.successfully_closed")
      return redirect_to action: :edit, id: params[:url_name]
    }.on_error {
      flash[:error] = t("admin.listing_shapes.can_not_find_name", name: params[:url_name])
      return redirect_to action: :index
    }
  end

  def destroy
    can_delete_shape?(params[:url_name], all_shapes(community_id: @current_community.id, include_categories: true)).and_then { |s|
      listing_api.listings.update_all(community_id: @current_community.id, query: { listing_shape_id: s[:id] }, opts: { open: false, listing_shape_id: nil })
    }.and_then {
      listing_api.shapes.delete(
        community_id: @current_community.id,
        name: params[:url_name]
      )
    }.on_success { |deleted_shape|
      flash[:notice] = t("admin.listing_shapes.successfully_deleted", order_type: t(deleted_shape[:name_tr_key]))
    }.on_error { |error_msg|
      flash[:error] = "Cannot delete order type, error: #{error_msg}"
    }

    redirect_to action: :index
  end

  private

  def filter_uneditable_fields(shape, process_summary)
    uneditable_keys = uneditable_fields(process_summary, shape[:author_is_seller]).select { |_, uneditable| uneditable }.keys
    shape.except(*uneditable_keys)
  end

  def uneditable_fields(process_summary, author_is_seller)
    {
      shipping_enabled: !process_summary[:preauthorize_available] || !author_is_seller,
      online_payments: !process_summary[:preauthorize_available] || !author_is_seller,
    }
  end

  def render_new_form(form, process_summary, available_locs)
    locals = common_locals(form, 0, process_summary, available_locs)
    render("new", locals: locals)
  end

  def render_edit_form(url_name, form, process_summary, available_locs)
    can_delete_res = can_delete_shape?(url_name, all_shapes(community_id: @current_community.id, include_categories: true))
    cant_delete = !can_delete_res.success
    cant_delete_reason = cant_delete ? can_delete_res.error_msg : nil

    count = listing_api.listings.count(
      community_id: @current_community.id,
      query: {
        listing_shape_id: form[:id],
        open: true
      }).data

    locals = common_locals(form, count, process_summary, available_locs).merge(
      url_name: url_name,
      name: pick_translation(form[:name]),
      cant_delete: cant_delete,
      cant_delete_reason: cant_delete_reason
    )
    render("edit", locals: locals)
  end

  def common_locals(form, count, process_summary, available_locs)
    { selected_left_navi_link: LISTING_SHAPES_NAVI_LINK,
      uneditable_fields: uneditable_fields(process_summary, form[:author_is_seller]),
      shape: FormViewLayer.shape_to_locals(form),
      count: count,
      locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h
    }
  end

  def can_delete_shape?(current_shape_name, shapes)
    listing_shapes_categories_map = shapes.map { |shape|
      [shape[:name], shape[:category_ids]]
    }

    categories_listing_shapes_map = HashUtils.transpose(listing_shapes_categories_map)

    last_in_category_ids = categories_listing_shapes_map.select { |category_id, shape_names|
      shape_names.size == 1 && shape_names.include?(current_shape_name)
    }.keys

    shape = shapes.find { |s| s[:name] == current_shape_name }

    if !shape
      Result::Error.new(t("admin.listing_shapes.can_not_find_name", name: current_shape_name))
    elsif shapes.length == 1
      Result::Error.new(t("admin.listing_shapes.edit.can_not_delete_last"))
    elsif !last_in_category_ids.empty?
      categories = ListingService::API::Api.categories.get_all(community_id: @current_community).data
      category_names = pick_category_names(categories, last_in_category_ids, I18n.locale)

      Result::Error.new(t("admin.listing_shapes.edit.can_not_delete_only_one_in_categories", categories: category_names.join(", ")))
    else
      Result::Success.new(shape)
    end
  end

  def pick_category_names(categories, ids, locale)
    locale = locale.to_s

    pick_categories(categories, ids)
      .map { |c| Maybe(c[:translations].find { |t| t[:locale] == locale }).or_else(c[:translations].first) }
      .map { |t| t[:name] }
  end

  def pick_categories(category_tree, ids)
    category_tree.reduce([]) { |acc, category|
      if ids.include?(category[:id])
        acc << category
      end

      if category[:children].present?
        acc.concat(pick_categories(category[:children], ids))
      end

      acc
    }
  end

  def listing_api
    ListingService::API::Api
  end

  def all_shapes(community_id:, include_categories:)
    listing_api.shapes.get(community_id: community_id, include_categories: include_categories)
      .maybe()
      .or_else([])
  end

  def process_summary
    @process_summary ||= processes.reduce({}) { |info, process|
      info[:preauthorize_available] = true if process[:process] == :preauthorize
      info[:request_available] = true if process[:author_is_seller] == false
      info
    }
  end

  def processes
    @processes ||= TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]
  end

  def validate_shape(form)
    form = Shape.call(form)

    errors = []

    if form[:shipping_enabled] && !form[:online_payments]
      errors << "Shipping cannot be enabled without online payments"
    end

    if form[:online_payments] && !form[:price_enabled]
      errors << "Online payments cannot be enabled without price"
    end

    if (form[:units].present? || form[:custom_units].present?) && !form[:price_enabled]
      errors << "Price units cannot be used without price field"
    end

    if errors.empty?
      Result::Success.new(form)
    else
      Result::Error.new(errors.join(", "))
    end
  end

  def pick_translation(translations)
    translations.find { |(locale, translation)|
      locale.to_s == I18n.locale.to_s
    }.second
  end

  def ensure_no_braintree_or_checkout
    gw = PaymentGateway.where(community_id: @current_community.id).first
    if !@current_user.is_admin? && gw
      flash[:error] = "Not available for your payment gateway: #{gw.type}"
      redirect_to admin_details_edit_path
    end
  end

  # FormViewLayer provides helper functions to transform:
  # - Shape hash to renderable format
  # - params from form back to Shape
  #
  module FormViewLayer
    module_function

    def params_to_shape(params)
      form_params = HashUtils.symbolize_keys(params)

      units = parse_predefined_units(form_params[:units])
        .concat(parse_existing_custom_units(Maybe(form_params)[:custom_units][:existing].or_else([])))
        .concat(parse_new_custom_units(Maybe(form_params)[:custom_units][:new].or_else([])))

      parsed_params = form_params.merge(
        units: units,
        author_is_seller: form_params[:author_is_seller] == "false" ? false : true # default true
      )

      Shape.call(parsed_params)
    end

    def shape_to_locals(shape)
      shape = Shape.call(shape)

      shape.merge(
        predefined_units: expand_predefined_units(shape[:units]),
        custom_units: encode_custom_units(shape[:units].select { |unit| unit[:type] == :custom })
      )
    end

    # private

    def expand_predefined_units(shape_units)
      shape_units_set = shape_units.map { |t| t[:type] }.to_set

      ListingShapeHelper.predefined_unit_types
        .map { |t| {type: t, enabled: shape_units_set.include?(t), label: I18n.t("admin.listing_shapes.units.#{t}")} }
    end

    def encode_custom_units(custom_units)
      custom_units.map { |u|
        {
          name: u[:name],
          value: ListingShapeDataTypes::Unit.serialize(u)
        }
      }
    end

    def parse_predefined_units(selected_units)
      (selected_units || []).map { |type, _| {type: type.to_sym, enabled: true}}
    end

    def parse_existing_custom_units(existing_units)
      existing_units.map { |_, unit|
        ListingShapeDataTypes::Unit.deserialize(unit)
          .merge({type: :custom, enabled: true})
      }
    end

    def parse_new_custom_units(new_units)
      new_units.map(&:second).map { |u|
        u.merge(type: :custom, enabled: true)
          .except(:name_tr_key, :selector_tr_key)
      }
    end
  end

  # The shape name is used as 'id'
  def set_url_name
    params[:url_name] = params[:id]
    params.delete :id
  end
end
