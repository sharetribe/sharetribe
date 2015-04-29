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
    unless h.all? { |(k, v)| k.is_a?(String) && v.is_a?(String) }
      {code: :form_translation_hash_format, msg: "Value must be a hash of { locale => translations }" }
    end
  }

  FormUnit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :optional],
    [:label, :string, :optional]
  )

  # Form can be passed to view to render the form.
  # Also, form can be constructed from the params.
  # Form can be passed to ShapeService and it will handle saving it
  Form = EntityUtils.define_builder(
    [:name, :hash, :mandatory, validate_with: FORM_TRANSLATION],
    [:action_button_label, :hash, :mandatory, validate_with: FORM_TRANSLATION],
    [:shipping_enabled, transform_with: CHECKBOX],
    [:price_enabled, transform_with: CHECKBOX],
    [:online_payments, transform_with: CHECKBOX],
    [:units, default: [], collection: FormUnit],
    [:template, :to_symbol]
  )

  TR_KEY_PROP_FORM_NAME_MAP = {
    name_tr_key: :name,
    action_button_tr_key: :action_button_label
  }
end
