class DateValidator < ActiveModel::Validator

  # Implements date validators.
  #
  # ## on_or_after validator
  #
  # Usage:
  #
  # ```
  # validates_with DateValidator,
  #                attribute: :end_on,
  #                compare_to: :start_on,
  #                restriction: :on_or_after
  # ```
  #
  def validate(record)

    case options[:restriction]
    when :on_or_after
      on_or_after(record, options) # options is inherited
    else
      raise ArgumentError.new("Unknown restriction #{options[:restriction]}")
    end

  end

  private

  def on_or_after(record, opts)
    attribute = attribute_to_date(record, opts[:attribute])
    compare_to = attribute_to_date(record, opts[:compare_to])

    if attribute.present? && compare_to.present?
      valid = attribute >= compare_to

      unless valid
        record.errors.add(
          :end_on,
          :on_or_after,
          restriction: format_date(compare_to))
      end
    end
  end

  def attribute_to_date(record, field)
    Maybe(field).map { |field_name|
      record.send(field_name)
    }.to_date.or_else(nil)
  end

  def format_date(date)
    date.strftime("%Y-%m-%d")
  end
end
