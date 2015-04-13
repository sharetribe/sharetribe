module ListingViewUtils

  module_function

  # parameters:
  # - units, array from shape[:units]
  # - selected, hash of {type, quantity_selector, translation_key}
  # units => [
  #   ['day', {type: 'day', quantity_selector: 'day'}, false]
  #   ['hour', {type: 'hour', quantity_selector: 'number'}, false]
  #   ['three hours', {type: 'custom', quantity_selector: 'number', translation_key: 'abcd-1231-12332-accc}, false]
  # ]
  def unit_options(units, tr_opts, selected_unit = nil)
    units.map { |unit|
      value = encode_unit(unit)
      # is_selected = unit_equals?(unit, selected_unit)
      is_selected = unit == selected_unit

      {
        display: translate_unit(unit, tr_opts),
        value: value,
        selected: is_selected
      }
    }
  end

  def unit_equals?(a, b)
    unit[:unit_type] == shape_unit[:unit_type] &&
    unit[:quantity_selector] == shape_unit[:quantity_selector] &&
    unit[:translation_key] == shape_unit[:translation_key]
  end

  def encode_unit(unit)
    HashUtils.compact(unit).to_json
  end

  def decode_unit(unit)
    json = JSON.parse(unit)

    HashUtils.compact(
      {
        type: json["type"].to_sym,
        quantity_selector: json["quantity_selector"].to_sym,
        translation_key: json["translation_key"]
      })
  end

  def translate_unit(unit, tr_opts)
    if unit[:translation_key]
      TranslationServiceHelper.pick(unit[:translation_key], tr_opts)
    else
      case unit[:type]
      when :day
        I18n.translate("listings.unit_types.day")
      else
        "No translation for builtin unit type #{unit[:type].inspect}"
      end
    end
  end
end
