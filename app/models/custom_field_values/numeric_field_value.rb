class NumericFieldValue < CustomFieldValue
  attr_accessible :numeric_value
  validates_numericality_of :numeric_value
end