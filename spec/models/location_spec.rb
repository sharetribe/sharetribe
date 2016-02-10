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
      l = Location.new(:address => "Otaniementie 19, Espoo, Finland")
      expect(l).to be_valid

      expect(l.latitude).to be_nil
      expect(l.longitude).to be_nil
      l.search_and_fill_latlng

      expect(l.latitude.to_s).to eq("60.1870405")
      expect(l.longitude.to_s).to eq("24.8163511")
    end
  end
end
