class DropdownField < CustomField
  def with_type(&block)
    block.call(:dropdown)
  end

  def selected_option_id_for(listing)
    answer = answer_for(listing)

    if answer
      selected_option = answer.selected_options.first.custom_field_option # Select first, dropdown only has one answer
      return selected_option.id
    end
  end
end
