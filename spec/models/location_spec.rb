# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  latitude       :float
#  longitude      :float
#  address        :string(255)
#  google_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  listing_id     :integer
#  person_id      :string(255)
#  location_type  :string(255)
#  community_id   :integer
#

require 'spec_helper'

describe Location do
  describe "#search_and_fill_latlng" do
    it "should store correct lat long coordinates" do
      l = Location.new(:address => "Otaniementie 19, Espoo, Finland")
      l.should be_valid

      l.latitude.should be_nil
      l.longitude.should be_nil
      l.search_and_fill_latlng

      l.latitude.to_s.should == "60.1870405"
      l.longitude.to_s.should == "24.8163511"
    end
  end
end
