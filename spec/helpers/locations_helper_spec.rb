require 'spec_helper'

include LocationsHelper

describe LocationsHelper do
  describe "#route_duration_and_distance" do

    
    context "waypoints are not given" do
      it "should return the duration in minutes and the distance in km between origin and destination" do
        results = LocationsHelper.route_duration_and_distance("Otakaari 20", "Kaironkatu 2")
        results.should be_an_instance_of(Array)
        results[0].should be_close(22, 0.5)
        results[1].should be_close(12.5, 0.2)
      end
    end
    
    context "waypoints are given" do
      it "should return the sum of durations and distances when whole route is traveled." do
        results = LocationsHelper.route_duration_and_distance("Otakaari 20", "Kaironkatu 2", ["ruoholahti,helsinki", "hakaniemen tori,helsinki"])
        results.should be_an_instance_of(Array)
        results[0].should be_close(30, 0.5)
        results[1].should be_close(16.6, 0.2)
      end
      
    end
    
  end
  
end