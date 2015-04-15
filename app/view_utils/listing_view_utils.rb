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
  def unit_options(units, selected_unit = nil)
    units.map { |unit|
      value = encode_unit(unit)
      is_selected = unit == selected_unit

      {
        display: translate_unit(unit[:type], unit[:translation_key]),
        value: value,
        selected: is_selected
      }
    }
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

  def translate_unit(type, tr_key)
    case type
    when :hour
      I18n.translate("listings.unit_types.hour")
    when :day
      I18n.translate("listings.unit_types.day")
    when :night
      I18n.translate("listings.unit_types.night")
    when :week
      I18n.translate("listings.unit_types.week")
    when :month
      I18n.translate("listings.unit_types.month")
    when :custom
      I18n.translate(tr_key)
    else
      raise ArgumentError.new("No translation for unit type: #{type}, translation_key: #{tr_key}")
    end
  end

  def translate_quantity(type)
    case type
    when :hour
      I18n.translate("listings.quantity.hour")
    when :day
      I18n.translate("listings.quantity.day")
    when :night
      I18n.translate("listings.quantity.night")
    when :week
      I18n.translate("listings.quantity.week")
    when :month
      I18n.translate("listings.quantity.month")
    when :custom
      I18n.translate("listings.quantity.custom")
    else
      raise ArgumentError.new("No translation for unit quantity: #{type}")
    end
  end
end
