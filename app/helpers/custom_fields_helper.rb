module CustomFieldsHelper
  
  def custom_field_dropdown_options(options)
    options.collect { |option| [t("admin.custom_fields.field_types.#{option[0]}"), option[1]] }
  end
  
end