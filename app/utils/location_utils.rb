module LocationUtils
  module_function

  def center(lat1, lng1, lat2, lng2)
    # Midway point along a great circle path between the two corners
    unless (lat1.present? && lng1.present? && lat2.present? && lng2.present?)
      ArgumentError.new("Two coordinate pairs required: \"#{lat1},#{lng1}; #{lat2},#{lng2}\"")
    end
    bx = Math.cos(lat2) * Math.cos(lng2 - lng1)
    by = Math.cos(lat2) * Math.sin(lng2 - lng1)
    lat_c = Math.atan2(Math.sin(lat1) + Math.sin(lat2),
                       Math.sqrt((Math.cos(lat1) + bx) * (Math.cos(lat1) + bx) + by * by))
    lng_c = lng1 + Math.atan2(by, Math.cos(lat1) + bx)
    { latitude: to_degrees(lat_c), longitude: to_degrees(lng_c) }
  end

  def to_radians(deg)
    deg_f = deg.is_a?(Numeric) ? deg : deg.to_f
    deg_f * Math::PI / 180
  end

  def to_degrees(rad)
    rad_f = rad.is_a?(Numeric) ? rad : rad.to_f
    rad_f / Math::PI * 180
  end
end