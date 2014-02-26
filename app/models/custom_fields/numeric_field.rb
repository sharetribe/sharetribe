class NumericField < CustomField

  validates_presence_of :min
  validates_presence_of :max
  
  def with_type(&block)
    block.call(:numeric)
  end

  def value_type
    "NumericFieldValue"
  end

end