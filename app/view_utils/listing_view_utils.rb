module ListingViewUtils
  extend MoneyRails::ActionViewExtension

  module_function

  # parameters:
  # - units, array from shape[:units]
  # - selected, symbol of unit type
  #
  # units => [
  #   ['Day', :day, true]
  #   ['Hour', :hour, false]
  # ]
  def unit_options(units, selected_unit = nil)
    units.map { |unit|
      {
        display: translate_unit(unit[:type], unit[:name_tr_key]),
        value: unit[:type],
        selected: unit == selected_unit
      }
    }
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

  def translate_quantity(type, tr_key = nil)
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
      if (tr_key)
        I18n.translate(tr_key)
      else
        I18n.translate("listings.quantity.custom")
      end
    else
      raise ArgumentError.new("No translation for unit quantity: #{type}")
    end
  end

  def shipping_info(shipping_type, shipping_price, shipping_price_additional)
    if shipping_type == :shipping && shipping_price_additional.present?
      I18n.translate("listings.show.shipping_price_additional", price: humanized_money_with_symbol(shipping_price), shipping_price_additional: humanized_money_with_symbol(shipping_price_additional))
    elsif shipping_type == :shipping
      I18n.translate("listings.show.shipping", price: humanized_money_with_symbol(shipping_price))
    elsif shipping_type == :pickup
      I18n.translate("listings.show.pickup", price: humanized_money_with_symbol(shipping_price))
    else
      raise ArgumentError.new("Delivery type not supported")
    end
  end
end
