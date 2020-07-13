module Admin2::Listings
  class OrderTypesController < Admin2::AdminBaseController

    include FormViewLayer

    def index
      @category_count = @current_community.categories.count
      @templates = ListingShapeTemplates.new(process_summary).label_key_list
      @listing_shapes = @current_community.shapes
    end

    def new
      if params[:type_id].present?
        @template = ListingShapeTemplates.new(process_summary)
                      .find(params[:type_id],
                            available_locales.map(&:second))
        @locals = common_locals(form: @template,
                                count: 0,
                                process_summary: process_summary,
                                available_locs: available_locales)
      end
      render layout: false
    end

    def edit
      url_name = ListingShape.find(params[:id]).name
      form = ShapeService.new(processes).get(
        community: @current_community,
        name: url_name,
        locales: available_locales.map { |_, locale| locale }
      ).data
      count = @current_community.listings.currently_open.where(listing_shape_id: form[:id]).count
      @locals = common_locals(form: form, count: count,
                              process_summary: process_summary,
                              available_locs: available_locales).merge(id: params[:id],
                                                                       name: pick_translation(form[:name]))
      render layout: false
    end

    def update
      params[:id] = params[:id].to_i
      shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)
      url_name = ListingShape.find(params[:id]).name
      update_result = validate_shape(shape).and_then { |s|
        ShapeService.new(processes).update(
          community: @current_community,
          name: url_name,
          opts: s)
      }
      unless update_result.success
        raise t('admin2.order_types.update_failure', error_msg: update_result.error_msg)
      end

      flash[:notice] = t('admin2.order_types.update_success', shape: pick_translation(shape[:name]))
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_order_types_path
    end

    def add_unit
      @data = { locals: params['unit_label'].keys,
                uniq: DateTime.current.strftime('%Q'),
                unit_label: params['unit_label'],
                selector_label: params['selector_label'],
                unit_type: params['unit_type'] }
      render layout: false
    end

    def create
      shape = filter_uneditable_fields(FormViewLayer.params_to_shape(params), process_summary)

      create_result = validate_shape(shape).and_then { |s|
        ShapeService.new(processes).create(
          community: @current_community,
          default_locale: @current_community.default_locale,
          opts: s)
      }
      unless create_result.success
        raise t('admin2.order_types.create_failure', error_msg: create_result.error_msg)
      end

      flash[:notice] = t('admin2.order_types.create_success', shape: pick_translation(shape[:name]))
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_order_types_path
    end

    def destroy
      shape = ListingShape.find(params[:id])
      url_name = shape.name
      raise t('admin2.order_types.errors.cannot_delete_msg', error_msg: shape.delete_shape_msg) unless shape.can_delete_shape?

      @current_community.listings.where(listing_shape_id: shape.id).update_all(open: false, listing_shape_id: nil) # rubocop:disable Rails/SkipsModelValidations
      deleted_shape = @current_community.shapes.by_name(url_name).first
      raise t('admin2.order_types.errors.cannot_delete') unless deleted_shape

      deleted_shape.update(deleted: true)
      flash[:notice] = t('admin2.order_types.successfully_deleted', order_type: t(deleted_shape[:name_tr_key]))
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_order_types_path
    end

    def order
      params[:ids]&.each do |index, object|
        ListingShape.find(object['id']).update(sort_priority: object['position'])
      end
      head :ok
    end

    def process_summary
      @process_summary ||= processes.each_with_object({}) { |process, info|
        info[:preauthorize_available] = true if process.process == :preauthorize
        info[:request_available] = true if process.author_is_seller == false
      }
    end

    def processes
      @processes ||= TransactionService::API::Api.processes.get(community_id: @current_community.id)[:data]
    end

    private

    def pick_translation(translations)
      translations.find { |(locale, _translation)|
        locale.to_s == I18n.locale.to_s
      }.second
    end

    def validate_shape(form)
      form = Shape.call(form)
      errors = []
      if form[:shipping_enabled] && !form[:online_payments]
        errors << t('admin2.order_types.errors.without_online_payments')
      end
      if form[:online_payments] && !form[:price_enabled]
        errors << t('admin2.order_types.errors.enabled_without_price')
      end
      if (form[:units].present? || form[:custom_units].present?) && !form[:price_enabled]
        errors << t('admin2.order_types.errors.used_without_price')
      end
      if errors.empty?
        Result::Success.new(form)
      else
        Result::Error.new(errors.join(", "))
      end
    end

    def filter_uneditable_fields(shape, process_summary)
      uneditable_keys = uneditable_fields(process_summary, shape[:author_is_seller]).select { |_, uneditable| uneditable }.keys
      shape.except(*uneditable_keys)
    end

    def common_locals(form:, count:, process_summary:, available_locs:)
      { uneditable_fields: uneditable_fields(process_summary, form[:author_is_seller]),
        shape: FormViewLayer.shape_to_locals(form),
        count: count,
        display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles.to_s == 'true',
        locale_name_mapping: available_locs.map { |name, l| [l, name] }.to_h }
    end

    def uneditable_fields(process_summary, author_is_seller)
      { shipping_enabled: !process_summary[:preauthorize_available] || !author_is_seller,
        online_payments: !process_summary[:preauthorize_available] || !author_is_seller,
        availability: !process_summary[:preauthorize_available] || !author_is_seller }
    end

  end
end
