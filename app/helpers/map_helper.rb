module MapHelper
  EARTH_RADIUS = 6371000 # meters
  DEG_TO_RAD = Math::PI / 180.0
  THREE_PI = Math::PI * 3
  TWO_PI = Math::PI * 2
  FUZZY_OFFSET = 500

  def deg_to_radians(lat, lng)
    [lat * DEG_TO_RAD, lng * DEG_TO_RAD]
  end

  def rad_to_degrees(lat, lng)
    [lat / DEG_TO_RAD, lng / DEG_TO_RAD]
  end

  def obfuscated_coordinates(init_lat, init_lng)
    unless init_lat && init_lng
      return [nil, nil]
    end

    lat, lng = deg_to_radians(init_lat, init_lng)
    sin_lat = Math.sin(lat)
    cos_lat = Math.cos(lat)

    randomize_bearing = rand
    randomize_distance = rand

    # Randomize distance and bearing
    distance = randomize_distance * FUZZY_OFFSET
    bearing = randomize_bearing * TWO_PI
    theta = distance / EARTH_RADIUS
    sin_bearing = Math.sin(bearing)
    cos_bearing = Math.cos(bearing)
    sin_theta = Math.sin(theta)
    cos_theta = Math.cos(theta)

    new_lat = Math.asin(sin_lat * cos_theta + cos_lat * sin_theta * cos_bearing)
    new_lng =
      lng + Math.atan2(sin_bearing * sin_theta * cos_lat, cos_theta - sin_lat * Math.sin(new_lat))

    # Normalize -PI -> +PI radians
    new_lng_normalized = ((new_lng + THREE_PI) % TWO_PI) - Math::PI

    rad_to_degrees(new_lat, new_lng_normalized)
  end

  def listings_for_map(listings)
    listings.map do |listing|
      result = {
        category: listing[:category_id],
        id: listing[:id],
        icon: listing[:icon_name],
        latitude: listing[:latitude],
        longitude: listing[:longitude]
      }
      if @current_community.fuzzy_location
        latitude, longitude = obfuscated_coordinates(listing[:latitude], listing[:longitude])
        result[:latitude] = latitude
        result[:longitude] = longitude
      end
      result
    end
  end
end
