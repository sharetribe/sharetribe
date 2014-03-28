class NumericField < CustomField
  attr_accessible :allow_decimals

  validates_numericality_of :min
  validates_numericality_of :max, greater_than: :min

  def display_min
    allow_decimals ? min : min.to_i
  end

  def display_max
    allow_decimals ? max : max.to_i
  end

  def with_type(&block)
    block.call(:numeric)
  end
end
