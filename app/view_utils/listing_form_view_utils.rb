module ListingFormViewUtils
  module_function

  def filter(params, shape, valid_until_enabled)
    filter_fields = []
    filter_fields << :price unless shape[:price_enabled]
    filter_fields << :currency unless shape[:price_enabled]
    filter_fields << :unit unless shape_units(shape).present?
    filter_fields << :shipping_price unless shape[:shipping_enabled]
    filter_fields << :shipping_price_additional unless shape[:shipping_enabled]
    filter_fields << :delivery_methods unless shape[:shipping_enabled]
    filter_fields << ["valid_until(1i)", "valid_until(2i)", "valid_until(3i)"] unless valid_until_enabled

    params.except(*filter_fields.flatten)
  end

  def filter_additional_shipping(params, unit)
    if unit[:kind] != 'quantity'
      params.except(:shipping_price_additional)
    else
      params
    end
  end

  def shape_units(shape)
    shape.is_a?(Hash) ? shape[:units] : shape.units
  end

  def validate(params:, shape:, unit:, valid_until_enabled: false)
    errors = []

    errors << :price_required if shape[:price_enabled] && params[:price].nil?
    errors << :currency_required if shape[:price_enabled] && params[:currency].blank?
    errors << :delivery_method_required if shape[:shipping_enabled] && params[:delivery_methods].empty?
    errors << :unknown_delivery_method if shape[:shipping_enabled] && params[:delivery_methods].any? { |method| !["shipping", "pickup"].include?(method) }

    errors << :unit_required if shape_units(shape).present? && unit.blank?
    errors << :unit_does_not_belong if shape_units(shape).present? && unit.present? && !shape_units(shape).any? { |u| u.slice(*unit.keys) == unit }

    errors << :valid_until_missing if valid_until_enabled && ["valid_until(1i)", "valid_until(2i)", "valid_until(3i)"].any? { |key| params[key].blank? }

    if errors.empty?
      Result::Success.new
    else
      Result::Error.new("Invalid listing parameters", errors)
    end
  end

  def normalize_price_params(listing_params)
    currency = listing_params[:currency]
    listing_params.inject({}) do |hash, (k, v)|
      case k
      when "price"
        hash.merge(:price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price"
        hash.merge(:shipping_price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price_additional"
        hash.merge(:shipping_price_additional_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      else
        hash.merge(k.to_sym => v)
      end
    end
  end

  def parse_listing_unit_param(params)
    unit_string = params.to_unsafe_hash[:listing][:unit]
    unit_string.present? ? HashUtils.symbolize_keys(JSON.parse(unit_string)) : {}
  end

  def build_listing_params(shape, listing_uuid, params, current_community)
    with_currency = params.to_unsafe_hash[:listing].merge({currency: current_community.currency})
    valid_until_enabled = !current_community.hide_expiration_date
    listing_params = filter(with_currency, shape, valid_until_enabled)
    listing_unit   = parse_listing_unit_param(params)
    listing_params = filter_additional_shipping(listing_params, listing_unit)
    validation_result = validate(
      params: listing_params,
      shape: shape,
      unit: listing_unit,
      valid_until_enabled: valid_until_enabled
    )

    return validation_result unless validation_result.success

    listing_params = normalize_price_params(listing_params)
    m_unit = select_unit(listing_unit, shape)

    listing_params = create_listing_params(listing_params).merge(
        uuid_object: listing_uuid,
        community_id: current_community.id,
        listing_shape_id: shape[:id],
        transaction_process_id: shape[:transaction_process_id],
        shape_name_tr_key: shape[:name_tr_key],
        action_button_tr_key: shape[:action_button_tr_key],
        availability: shape[:availability]
    ).merge(unit_to_listing_opts(m_unit)).except(:unit)

    Result::Success.new(listing_params)
  end

  def select_unit(listing_unit, shape)
    Maybe(shape).units.map { |units|
      if units.length == 1
        units.first
      else
        units.find { |u| u.compact == listing_unit }
      end
    }
  end

  def create_listing_params(params)
    listing_params = params.except(:delivery_methods).merge(
      require_shipping_address: Maybe(params[:delivery_methods]).map { |d| d.include?("shipping") }.or_else(false),
      pickup_enabled: Maybe(params[:delivery_methods]).map { |d| d.include?("pickup") }.or_else(false),
      price_cents: params[:price_cents],
      shipping_price_cents: params[:shipping_price_cents],
      shipping_price_additional_cents: params[:shipping_price_additional_cents],
      currency: params[:currency]
    )

    add_location_params(listing_params, params)
  end

  def add_location_params(listing_params, params)
    if params[:origin_loc_attributes].nil?
      listing_params
    else
      params = ActionController::Parameters.new(params)
      location_params = permit_location_params(params).merge(location_type: :origin_loc)

      listing_params.merge(
        origin_loc_attributes: location_params
      )
    end
  end

  def permit_location_params(params)
    p = if params[:location].present?
          params.require(:location)
        elsif params[:origin_loc_attributes].present?
          params.require(:origin_loc_attributes)
        elsif params[:listing].present? && params[:listing][:origin_loc_attributes].present?
          params.require(:listing).require(:origin_loc_attributes)
        end
    p.permit(:address, :google_address, :latitude, :longitude) if p.present?
  end

  def unit_to_listing_opts(m_unit)
    m_unit.map { |unit|
      {
        unit_type: unit[:unit_type],
        quantity_selector: unit[:quantity_selector],
        unit_tr_key: unit[:name_tr_key],
        unit_selector_tr_key: unit[:selector_tr_key]
      }
    }.or_else({
        unit_type: nil,
        quantity_selector: nil,
        unit_tr_key: nil,
        unit_selector_tr_key: nil
    })
  end
end
