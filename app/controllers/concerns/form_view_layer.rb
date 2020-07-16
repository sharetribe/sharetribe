# FormViewLayer provides helper functions to transform:
# - Shape hash to renderable format
# - params from form back to Shape
#
module FormViewLayer
  module_function

  Shape = ListingShapeDataTypes::Shape

  def params_to_shape(params)
    form_params = HashUtils.symbolize_keys(params.to_unsafe_hash)

    parsed_params = form_params.merge(
      units: parse_units_from_params(form_params),
      author_is_seller: form_params[:author_is_seller] != "false" # default true
    )

    Shape.call(parsed_params)
  end

  def shape_to_locals(shape)
    shape = Shape.call(shape)

    units = split_availability_and_pricing_units(shape)

    shape.merge(
      availability_unit: units[:availability],
      predefined_units: expand_predefined_units(units[:pricing]),
      custom_units: encode_custom_units(units[:pricing].select { |unit| unit[:unit_type] == 'custom' })
    )
  end

  # private

  # Splits units to availability units and pricing units.
  #
  # In the backend we have only one concept, units. However, in the UI
  # we are showing pricing unit checkboxes and availability unit radio
  # buttons. This method maps backend units to the two unit formats
  # we have in the UI
  #
  def split_availability_and_pricing_units(shape)
    if shape[:availability] == 'booking'
      {
        pricing: [],
        availability: shape[:units].first[:unit_type]
      }
    else
      {
        pricing: shape[:units],
        availability: nil
      }
    end
  end

  # Combines availability units and pricing units to just "units".
  #
  # In the backend we have only one concept, units. However, in the UI
  # we are showing pricing unit checkboxes and availability unit radio
  # buttons. This method maps the UI units to backend units.
  #
  def parse_units_from_params(form_params)
    selected_predefined_units =
      if form_params[:availability] == "booking"
        [form_params[:availability_unit]]
      else
        form_params[:units]
      end

    parse_predefined_units(selected_predefined_units)
      .concat(parse_existing_custom_units(Maybe(form_params)[:custom_units][:existing].or_else([])))
      .concat(parse_new_custom_units(Maybe(form_params)[:custom_units][:new].or_else([])))
  end

  def expand_predefined_units(shape_units)
    shape_units_set = shape_units.map { |t| t[:unit_type] }.to_set

    ListingShapeHelper.predefined_unit_types
      .map { |t| {unit_type: t, enabled: shape_units_set.include?(t), label: I18n.t("admin.listing_shapes.units.#{t}")} }
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
    (selected_units || []).map { |type, _| {unit_type: type, enabled: true}}
  end

  def parse_existing_custom_units(existing_units)
    existing_units.map { |_, unit|
      ListingShapeDataTypes::Unit.deserialize(unit)
        .merge({unit_type: 'custom', enabled: true})
    }
  end

  def parse_new_custom_units(new_units)
    new_units.map(&:second).map { |u|
      u.merge(unit_type: 'custom', enabled: true)
        .except(:name_tr_key, :selector_tr_key)
    }
  end
end
