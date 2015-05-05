module ListingFormViewUtils
  module_function

  def filter(params, shape)
    filter_fields = []

    filter_fields << :price_cents unless shape[:price_enabled]
    filter_fields << :currency unless shape[:price_enabled]
    filter_fields << :unit_type unless shape[:units].present?
    filter_fields << :shipping_price_cents unless shape[:shipping_enabled]
    filter_fields << :shipping_price_additional_cents unless shape[:shipping_enabled]
    filter_fields << :require_shipping_address unless shape[:shipping_enabled]
    filter_fields << :pickup_enabled unless shape[:shipping_enabled]

    params.except(*filter_fields)
  end

  def validate(params, shape)
    errors = []

    errors << :price_required if (params[:price_cents].nil?) && shape[:price_enabled]
    errors << :currency_required if params[:currency].blank? && shape[:price_enabled]
    errors << :unit_required if params[:unit_type].blank? && shape[:units].present?
    errors << :quantity_selector_required if params[:quantity_selector].blank? && shape[:units].present?
    errors << :unit_does_not_belong if params[:unit_type].present? && !shape[:units].include?({type: params[:unit_type], quantity_selector: params[:quantity_selector]})
    errors << :delivery_method_required if (params[:require_shipping_address].nil? && params[:pickup_enabled].nil?) && shape[:shipping_enabled]

    if errors.empty?
      Result::Success.new
    else
      Result::Error.new("Invalid listing parameters", errors)
    end
  end

end
