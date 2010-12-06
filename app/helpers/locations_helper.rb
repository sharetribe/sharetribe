module LocationsHelper
  LAT_DEG_IN_KM = 111.2 #km distance between latitude degrees
  LON_DEG_IN_KM = 55.60 #km distance between longitude degrees at lat 60

  def distance_between(c1, c2)
    Math.sqrt(((c1[0]-c2[0])*LAT_DEG_IN_KM)**2 + ((c1[1]-c2[1])*LON_DEG_IN_KM)**2)
  end
  
  def get_coordinates(place_name)
    # FIXME: Currently hardcoded to prioritize Finland and Helsinki in serches. Should depend on the community. 
    url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{ApplicationHelper.escape_for_url(place_name)}&region=fi&sensor=false&bounds=#{ApplicationHelper.escape_for_url("59.5,24.5|60.5,25.5")}"
    response = JSON.parse(RestClient.get(url))
    raise RuntimeError.new("Coordinates for #{place_name} not found. (Message: #{response["status"]})") unless response["status"] == "OK"
    return [response["results"][0]["geometry"]["location"]["lat"], response["results"][0]["geometry"]["location"]["lng"]] 
  end

  def route_duration_and_distance(origin, destination, waypoints = [])
     # FIXME: Currently hardcoded to prioritize Finland in serches. Should depend on the community. 
      url = "http://maps.googleapis.com/maps/api/directions/json?origin=#{ApplicationHelper.escape_for_url(origin)}&destination=#{ApplicationHelper.escape_for_url(destination)}&sensor=false&region=fi"
      url += "&waypoints=#{ApplicationHelper.escape_for_url(waypoints.join("|"))}" unless waypoints.empty?
      
      response = JSON.parse(RestClient.get(url))
      raise RuntimeError.new("Could not get route details. (Message: #{response["status"]})") unless response["status"] == "OK"
      
      legs = response["routes"][0]["legs"]
      
      #calculate whole duration and distance
      duration = 0 #seconds
      distance = 0 #meters
      legs.each do |leg|
        duration += leg["duration"]["value"]
        distance += leg["distance"]["value"]
      end
      return [duration/60.0, distance/1000.0] #return as minutes and km.
    
  end

end
