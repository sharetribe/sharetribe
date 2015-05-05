module ListingFormViewUtils
  module_function

  def filter(params, shape)
    filter_fields = []

    filter_fields << :price_cents unless shape[:price_enabled]
    filter_fields << :currency unless shape[:price_enabled]
    filter_fields << :unit unless shape[:units].length > 1
    filter_fields << :shipping_price_cents unless shape[:shipping_enabled]
    filter_fields << :shipping_price_additional_cents unless shape[:shipping_enabled]
    filter_fields << :require_shipping_address unless shape[:shipping_enabled]
    filter_fields << :pickup_enabled unless shape[:shipping_enabled]

    params.except(*filter_fields)
  end

  def validate(params, shape)
    errors = []

    errors << :price_required if (params[:price_cents].nil? || params[:price_cents] == 0) && shape[:price_enabled]
    errors << :currency_required if params[:currency].blank? && shape[:price_enabled]
    errors << :unit_required if params[:unit].blank? && shape[:units].length > 1
    errors << :unit_does_not_belong if params[:unit].present? && !shape[:units].include?(params[:unit])
    errors << :delivery_method_required if (params[:require_shipping_address].nil? && params[:pickup_enabled].nil?) && shape[:shipping_enabled]

    if errors.empty?
      Result::Success.new
    else
      Result::Error.new("Invalid listing parameters", errors)
    end
  end

end
