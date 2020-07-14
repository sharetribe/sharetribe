module CustomFieldTypes
  extend ActiveSupport::Concern

  CHECKBOX_TO_BOOLEAN = ->(v) {
    if [false, true].include?(v)
      v
    else
      v == '1'
    end
  }

  HASH_VALUES = ->(v) {
    if v.is_a?(Array)
      v
    elsif v.is_a?(Hash)
      v.values
    elsif v.nil?
      nil
    else
      raise ArgumentError.new("Illegal argument given to transformer: #{v.to_inspect}")
    end
  }

  CategoryAttributeSpec = EntityUtils.define_builder(
    [:category_id, :fixnum, :to_integer, :mandatory]
  )

  OptionAttribute = EntityUtils.define_builder(
    [:id, :mandatory],
    [:sort_priority, :fixnum, :to_integer, :mandatory],
    [:title_attributes, :hash, :to_hash, :mandatory]
  )

  CUSTOM_FIELD_SPEC = [
    [:name_attributes, :hash, :mandatory],
    [:category_attributes, collection: CategoryAttributeSpec],
    [:sort_priority, :fixnum, :optional],
    [:required, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ]

  TextFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  NumericFieldSpec = [
    [:min, :mandatory],
    [:max, :mandatory],
    [:allow_decimals, :bool, :mandatory, transform_with: CHECKBOX_TO_BOOLEAN],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DropdownFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN],
  ] + CUSTOM_FIELD_SPEC

  CheckboxFieldSpec = [
    [:option_attributes, :mandatory, transform_with: HASH_VALUES, collection: OptionAttribute],
    [:search_filter, :bool, :optional, default: false, transform_with: CHECKBOX_TO_BOOLEAN]
  ] + CUSTOM_FIELD_SPEC

  DateFieldSpec = [
    [:search_filter, :bool, const_value: false]
  ] + CUSTOM_FIELD_SPEC

  TextFieldEntity     = EntityUtils.define_builder(*TextFieldSpec)
  NumericFieldEntity  = EntityUtils.define_builder(*NumericFieldSpec)
  DropdownFieldEntity = EntityUtils.define_builder(*DropdownFieldSpec)
  CheckboxFieldEntity = EntityUtils.define_builder(*CheckboxFieldSpec)
  DateFieldEntity     = EntityUtils.define_builder(*DateFieldSpec)

end
