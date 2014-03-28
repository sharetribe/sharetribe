class Location < ActiveRecord::Base

  belongs_to :person
  belongs_to :listing
  belongs_to :community

  def search_and_fill_latlng(address=nil, locale=APP_CONFIG.default_locale)
    okresponse = false
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address="

    if address == nil
      address = self.address
    end

    if address != nil && address != ""
      url = URI.escape(geocoder+address)
      resp = RestClient.get(url)
      result = JSON.parse(resp.body)

      if result["status"] == "OK"
        self.latitude = result["results"][0]["geometry"]["location"]["lat"]
        self.longitude = result["results"][0]["geometry"]["location"]["lng"]
        okresponse = true
      end
    end
    okresponse
  end

end
