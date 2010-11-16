module LocationsHelper
  LAT_DEG_IN_KM = 111.2 #km distance between latitude degrees
  LON_DEG_IN_KM = 55.60 #km distance between longitude degrees at lat 60

  def distance_between(c1, c2)
    Math.sqrt(((c1[0]-c2[0])*LAT_DEG_IN_KM)**2 + ((c1[1]-c2[1])*LON_DEG_IN_KM)**2)
  end
  
  def get_coordinates(place_name)
    escaped_place_name = ApplicationHelper.escape_for_url(place_name)
    # FIXME: Currently hardcoded to prioritize Finland and Helsinki in serches. Should depend on the community. 
    response = JSON.parse(RestClient.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_place_name}&region=fi&sensor=false&bounds=59.5,24.5|60.5,25.5"))
    raise RuntimeError.new("Coordinates for #{place_name} not found. (Message: #{response["status"]})") unless response["status"] == "OK"
    return [response["results"][0]["geometry"]["location"]["lat"], response["results"][0]["geometry"]["location"]["lng"]] 
  end

end