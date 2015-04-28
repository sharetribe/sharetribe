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

  Unit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory]
  )

  # Shape describes the data in Templates list.
  # Also, ShapeService.get returns Shape
  # Shape can be used to construct a Form
  Shape = EntityUtils.define_builder(
    [:label, :string, :optional], # Only for predefined templates
    [:template, :symbol, :optional], # Only for predefined templates
    [:name_tr_key, :string, :mandatory],
    [:action_button_tr_key, :string, :mandatory],
    [:price_enabled, :bool, :mandatory],
    [:shipping_enabled, :bool, :mandatory],
    [:online_payments, :bool, :mandatory],
    [:units, collection: Unit]
  )

  FormUnit = EntityUtils.define_builder(
    [:type, :symbol, :mandatory],
    [:enabled, :bool, :mandatory],
    [:label, :string, :optional]
  )

  # Form can be passed to view to render the form.
  # Also, form can be constructed from the params.
  # Form can be passed to ShapeService and it will handle saving it
  Form = EntityUtils.define_builder(
    [:name, :hash, :mandatory],
    [:action_button_label, :hash, :mandatory],
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
