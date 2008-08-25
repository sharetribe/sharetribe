my_formats = {
  :basic_date_format_minutes => "%d.%m.%Y %H:%M",
  :basic_date_format  => "%d.%m.%Y"
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)