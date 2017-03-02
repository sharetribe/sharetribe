module CustomFieldSearchParams

  DROPDOWN_PREFIX = "filter_option_"
  CHECKBOX_PREFIX = "checkbox_filter_option_"
  NUMERIC_PREFIX = "nf_"
  NUMERIC_MIN_PREFIX = NUMERIC_PREFIX + "min_"
  NUMERIC_MAX_PREFIX = NUMERIC_PREFIX + "max_"

  module_function

  def remove_irrelevant_search_params(params, relevant_search_fields)
    relevant_search_param_names = search_fields_to_param_names(relevant_search_fields)

    params.reject { |name|
      # Remove parameter if:
      # - it is a custom field search parameter
      # - it's not in the set of relevant param names
      #
      custom_field_search_param?(name) &&
        !relevant_search_param_names.include?(name)
    }
  end

  def search_fields_to_param_names(search_fields)
    search_fields.flat_map { |field|
      field_id, value, type, operator = field.values_at(:id, :value, :type, :operator)

      case [type, operator]
      when [:selection_group, :and]
        # Checkbox
        value.map { |option_id| checkbox_param_name(option_id) }
      when [:selection_group, :or]
        # Dropdown
        value.map { |option_id| dropdown_param_name(option_id) }
      when [:numeric_range, nil]
        # Numeric
        [numeric_min_param_name(field_id), numeric_max_param_name(field_id)]
      end
    }.compact.to_set
  end

  # CHECK if param is custom fields search param

  def custom_field_search_param?(param_name)
    dropdown_param?(param_name) ||
      checkbox_param?(param_name) ||
      numeric_min_param?(param_name) ||
      numeric_max_param?(param_name)
  end

  def dropdown_param?(param_name)
    param_name.starts_with?(DROPDOWN_PREFIX)
  end

  def checkbox_param?(param_name)
    param_name.starts_with?(CHECKBOX_PREFIX)
  end

  def numeric_min_param?(param_name)
    param_name.starts_with?(NUMERIC_MIN_PREFIX)
  end

  def numeric_max_param?(param_name)
    param_name.starts_with?(NUMERIC_MAX_PREFIX)
  end

  # CONSTRUCT param names

  def dropdown_param_name(option_id)
    DROPDOWN_PREFIX + option_id.to_s
  end

  def checkbox_param_name(option_id)
    CHECKBOX_PREFIX + option_id.to_s
  end

  def numeric_min_param_name(field_id)
    NUMERIC_MIN_PREFIX + field_id.to_s
  end

  def numeric_max_param_name(field_id)
    NUMERIC_MAX_PREFIX + field_id.to_s
  end
end
