class Location < ActiveRecord::Base

  belongs_to :person
  belongs_to :listing
  
  def search_and_fill_latlng(address=nil, locale=APP_CONFIG.default_locale)
    okresponse = false
    geocoder = "http://maps.google.com/maps/geo?q="
    output = "&output=csv"

    if address == nil
      address = self.address
    end

    if address != nil && address != ""
      url = URI.escape(geocoder+address+output)
      resp = Net::HTTP.get_response(URI.parse(url))
      addr = resp.body.split(',')
      if addr[0] == "200"
        self.latitude = addr[2].to_f
        self.longitude = addr[3].to_f
        okresponse = true
      end
    end
    okresponse
  end
  
end
