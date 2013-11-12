require 'spec_helper'

describe HomepageController do

  describe "selected view type" do

    it "returns param view type if param is present and it is one of the view types, otherwise comm default" do
      types = ["map", "list", "grid"]
      HomepageController.selected_view_type("map", "list", "grid", types).should == "map"
      HomepageController.selected_view_type(nil, "list", "grid", types).should == "list"
      HomepageController.selected_view_type("", "list", "grid", types).should == "list"
      HomepageController.selected_view_type("not_existing_view_type", "list", "grid", types).should == "list"
    end

    it "defaults to app default, if comm default is incorrect" do
      types = ["map", "list", "grid"]
      HomepageController.selected_view_type("", "list", "grid", types).should == "list"
      HomepageController.selected_view_type("", nil, "grid", types).should == "grid"
      HomepageController.selected_view_type("", "", "grid", types).should == "grid"
      HomepageController.selected_view_type("", "not_existing_view_type", "grid", types).should == "grid"
    end
  end

end
