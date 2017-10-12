# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  latitude       :float(24)
#  longitude      :float(24)
#  address        :string(255)
#  google_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  listing_id     :integer
#  person_id      :string(255)
#  location_type  :string(255)
#  community_id   :integer
#
# Indexes
#
#  index_locations_on_community_id  (community_id)
#  index_locations_on_listing_id    (listing_id)
#  index_locations_on_person_id     (person_id)
#

require 'spec_helper'

describe Location, type: :model do
  describe "#search_and_fill_latlng" do
    it "should store correct lat long coordinates" do
      stub_maps_googleapis
      l = Location.new(:address => "Bulevardi 14, Helsinki, Finland")
      expect(l).to be_valid

      expect(l.latitude).to be_nil
      expect(l.longitude).to be_nil
      l.search_and_fill_latlng

      expect(l.latitude.to_s).to eq("60.1651848")
      expect(l.longitude.to_s).to eq("24.939939")
    end
  end

  def stub_maps_googleapis
    results = {
      "results"=>
      [{"address_components"=>
         [{"long_name"=>"14", "short_name"=>"14", "types"=>["street_number"]},
          {"long_name"=>"Bulevardi",
           "short_name"=>"Bulevardi",
           "types"=>["route"]},
          {"long_name"=>"Helsinki",
           "short_name"=>"HKI",
           "types"=>["locality", "political"]},
          {"long_name"=>"Finland",
           "short_name"=>"FI",
           "types"=>["country", "political"]},
          {"long_name"=>"00120", "short_name"=>"00120", "types"=>["postal_code"]}],
        "formatted_address"=>"Bulevardi 14, 00120 Helsinki, Finland",
        "geometry"=>
         {"location"=>{"lat"=>60.1651848, "lng"=>24.939939},
          "location_type"=>"ROOFTOP",
          "viewport"=>
           {"northeast"=>{"lat"=>60.1665337802915, "lng"=>24.9412879802915},
            "southwest"=>{"lat"=>60.16383581970849, "lng"=>24.9385900197085}}},
        "place_id"=>"ChIJ6YBSzMsLkkYRIOsikn7B4eM",
        "types"=>["street_address"]}],
      "status"=>"OK"
    }
    stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=Bulevardi%2014,%20Helsinki,%20Finland")
      .to_return(status: 200, body: results.to_json, headers: {})
  end
end
