class DateFieldValue < CustomFieldValue

  attr_accessible :date_value

  validate :date_value_is_valid_datetime
  validates_presence_of :date_value

  # validate the date format (give an explicit error message for bad api requests)
  def date_value_is_valid_datetime
    errors.add(:date_value, 'must be a valid datetime') if ((DateTime.parse(date_value.to_s) rescue ArgumentError) == ArgumentError)
  end

end
