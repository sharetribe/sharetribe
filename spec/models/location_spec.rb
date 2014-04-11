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
