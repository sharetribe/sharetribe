class DateField < CustomField
  def with_type(&block)
    block.call(:date_field)
  end
end
