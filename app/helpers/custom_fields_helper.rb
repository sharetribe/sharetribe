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

  def field_type_translation_admin2(type)
    translation_map = {
      "DropdownField" => 'admin2.user_fields.field_types.dropdown',
      "TextField" => 'admin2.user_fields.field_types.text',
      "NumericField" => 'admin2.user_fields.field_types.number',
      "CheckboxField" => 'admin2.user_fields.field_types.checkbox_group',
      "DateField" => 'admin2.user_fields.field_types.date'
    }

    t(translation_map[type])
  end

  def custom_field_dropdown_options(options)
    options.collect { |option| [field_type_translation(option), option] }.insert(0, [t("admin.custom_fields.index.select_one"), nil])
  end

  def custom_field_dropdown_options_admin2(options)
    options.collect { |option| [field_type_translation_admin2(option), option] }.insert(0, [t('admin2.user_fields.select_one'), nil])
  end

end
