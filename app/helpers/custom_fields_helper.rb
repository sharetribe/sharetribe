module CustomFieldsHelper

  def field_type_translation(type)
    tranlation_map = {
      "DropdownField" => "admin.custom_fields.field_types.dropdown",
      "TextField" => "admin.custom_fields.field_types.text",
      "NumericField" => "admin.custom_fields.field_types.number",
      "CheckboxField" => "admin.custom_fields.field_types.checkbox_group",
      "DateField" => "admin.custom_fields.field_types.date"
    }

    t(tranlation_map[type])
  end

  def custom_field_dropdown_options(options)
    options.collect { |option| [field_type_translation(option), option] }.insert(0, [t("admin.custom_fields.index.select_one"), nil])
  end

end
