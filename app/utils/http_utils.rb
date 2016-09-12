module HTTPUtils
  module_function

  # Takes Content-type header value and returns the media type.
  #
  # Usage:
  #
  # HTTPUtils.parse_content_type("application/transit+msgpack;charset=UTF-8")
  #  => "application/transit+msgpack"
  #
  def parse_content_type(content_type)
    return nil if content_type.blank?

    media_type, = content_type.split(";")
    media_type.downcase.strip
  end
end
