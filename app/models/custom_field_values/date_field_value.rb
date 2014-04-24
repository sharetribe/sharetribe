class DateFieldValue < CustomFieldValue

  attr_accessible :date_value

  validates_presence_of :date_value

end
