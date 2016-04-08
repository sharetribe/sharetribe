module ListingViewUtils
  extend MoneyRails::ActionViewExtension

  Unit = EntityUtils.define_builder(
    [:type, :to_symbol, one_of: [:hour, :day, :night, :week, :month, :custom]],
    [:name_tr_key, :string, :optional],
    [:kind, :mandatory, :to_symbol],
    [:selector_tr_key, :string, :optional],
    [:quantity_selector, :to_symbol, one_of: ["".to_sym, :none, :number, :day]] # in the future include :hour, :week:, :night ,:month etc.
  )

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
          display: translate_unit(unit[:type], unit[:name_tr_key]),
          value: Unit.serialize(unit),
          kind: unit[:kind],
          selected: selected_unit.present? && HashUtils.sub_eq(renamed, selected_unit, :type, :unit_tr_key, :unit_selector_tr_key)
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

  # FIXME I feel that this is not quite right.
  # Instead of unit type, the first parameter should be selector type (number, day)
  # and that should affect how we should the information
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
