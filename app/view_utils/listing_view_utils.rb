module ListingViewUtils
  extend MoneyRails::ActionViewExtension

  module_function

  # parameters:
  # - units, array from shape[:units]
  # - selected, symbol of unit type
  #
  def unit_options(units, selected_unit = nil)
    units
      .map { |u| HashUtils.compact(u) }
      .map { |unit|
        renamed = HashUtils.rename_keys({name_tr_key: :unit_tr_key, selector_tr_key: :unit_selector_tr_key}, unit)
        {
          display: translate_unit(unit[:unit_type], unit[:name_tr_key]),
          value: unit.to_json,
          kind: unit[:kind],
          selected: selected_unit.present? && HashUtils.sub_eq(renamed, selected_unit, :unit_type, :unit_tr_key, :unit_selector_tr_key)
        }
      }
  end

  def translate_unit(type, tr_key, locale: nil)
    l = (locale || I18n.locale).to_sym

    case type.to_s
    when 'hour'
      I18n.translate("listings.unit_types.hour", locale: l)
    when 'day'
      I18n.translate("listings.unit_types.day", locale: l)
    when 'night'
      I18n.translate("listings.unit_types.night", locale: l)
    when 'week'
      I18n.translate("listings.unit_types.week", locale: l)
    when 'month'
      I18n.translate("listings.unit_types.month", locale: l)
    when 'unit'
      I18n.translate("listings.unit_types.unit", locale: l)
    when 'custom'
      I18n.translate(tr_key, locale: l)
    else
      raise ArgumentError.new("No translation for unit type: #{type}, translation_key: #{tr_key}")
    end
  end

  # FIXME I feel that this is not quite right.
  # Instead of unit type, the first parameter should be selector type (number, day)
  # and that should affect how we should the information
  def translate_quantity(type, tr_key = nil)
    case type.to_s
    when 'hour'
      I18n.translate("listings.quantity.hour")
    when 'day'
      I18n.translate("listings.quantity.day")
    when 'night'
      I18n.translate("listings.quantity.night")
    when 'week'
      I18n.translate("listings.quantity.week")
    when 'month'
      I18n.translate("listings.quantity.month")
    when 'unit'
      I18n.translate("listings.quantity.unit")
    when 'custom'
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
      I18n.translate("listings.show.shipping_price_additional",
                     price: MoneyViewUtils.to_humanized(shipping_price),
                     shipping_price_additional: MoneyViewUtils.to_humanized(shipping_price_additional))
    elsif shipping_type == :shipping
      I18n.translate("listings.show.shipping", price: MoneyViewUtils.to_humanized(shipping_price))
    elsif shipping_type == :pickup
      I18n.translate("listings.show.pickup", price: MoneyViewUtils.to_humanized(shipping_price))
    else
      raise ArgumentError.new("Delivery type not supported")
    end
  end

  def youtube_video_ids(text)
    return [] unless text.present? && text.is_a?(String)
    text.scan(/https?:\/\/\S+/).map { |l| youtube_video_id(l) }.compact
  end

  def youtube_video_id(link)
    return nil unless link.present? && link.is_a?(String)
    pattern = /^.*(?:(?:youtu\.be\/|youtu.*v\/|youtu.*embed\/)|youtu.*(?:\?v=|\&v=))([^#\&\?]*).*/
    Maybe(pattern.match(link))[1].or_else(nil)
  end

end
