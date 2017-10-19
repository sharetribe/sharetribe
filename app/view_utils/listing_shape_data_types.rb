module ListingShapeDataTypes

  # true -> true # idempotent
  # false -> false # idempotent
  # nil -> false
  # anything else -> true
  CHECKBOX = -> (value) {
    if value == true || value == false
      value
    else
      !value.nil?
    end
  }

  FORM_TRANSLATION = ->(h) {
    return if h.nil?
    unless h.all? { |(k, v)| k.is_a?(String) && v.is_a?(String) }
      {code: :form_translation_hash_format, msg: "Value must be a hash of { locale => translations }" }
    end
  }

  Unit = EntityUtils.define_builder(
    [:unit_type, :string, :mandatory],
    [:name, :hash, validate_with: FORM_TRANSLATION],
    [:kind, :string],
    [:selector, :hash, validate_with: FORM_TRANSLATION],
    [:name_tr_key, :string],
    [:selector_tr_key, :string]
  )

  # Shape datatype is ListingShapeController's internal representation of the listing shape.
  Shape = EntityUtils.define_builder(
    [:id, :fixnum],
    [:name, :hash, :optional, validate_with: FORM_TRANSLATION],
    [:action_button_label, :hash, :optional, validate_with: FORM_TRANSLATION],
    [:shipping_enabled, transform_with: CHECKBOX],
    [:price_enabled, transform_with: CHECKBOX],
    [:online_payments, transform_with: CHECKBOX],
    [:units, default: [], collection: Unit],
    [:author_is_seller, :bool],
    [:availability, :string, one_of: ['none', 'booking'], default: 'none'] # also stock, in the future
  )

  KEY_MAP = {
    name_tr_key: :name,
    action_button_tr_key: :action_button_label
  }

  CUSTOM_UNIT_KEY_MAP = {
    name_tr_key: :name,
    selector_tr_key: :selector
  }
end
