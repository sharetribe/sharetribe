class NumericField < CustomField
  validates_numericality_of :min
  validates_numericality_of :max, greater_than: :min
  
  def with_type(&block)
    block.call(:numeric)
  end
end