class DateOnOrAfterValidator < ActiveModel::Validator

  # Validates that `end_on` field date value is
  # on or after `start_on` value.
  # Note, the field names are hard-coded. If you need to change this,
  # you will probably need to inherit this class from EachValidator
  def validate(record)
    return if record.end_on.nil? || record.start_on.nil?

    start_on_date = record.start_on.to_date
    end_on_date = record.end_on.to_date

    unless end_on_date >= start_on_date
      formatted_start_on = start_on_date.strftime("%Y-%m-%d")
      record.errors.add(:end_on, I18n.t("errors.messages.on_or_after", restriction: formatted_start_on))
    end
  end

end
