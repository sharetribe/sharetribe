class TextField < CustomField
  
  def with_type(&block)
    block.call(:text_field)
  end

  def value_type
    "TextFieldValue"
  end

end