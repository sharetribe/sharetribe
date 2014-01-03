class DropdownField < CustomField
  def with_type(&block)
    block.call(:dropdown)
  end
end
