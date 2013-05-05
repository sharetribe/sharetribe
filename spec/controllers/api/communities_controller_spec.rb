require 'spec_helper'

describe Api::CommunitiesController do
  render_views
    
  describe "#show" do
    
    it "returns the full JSON of a community" do
      c = FactoryGirl.create(:community)
      l = FactoryGirl.create(:location, :community => c, :address => "antarctica")
      
      get :show, :id => c.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      
      #puts response.body
      
      resp["id"].should == c.id
      resp["name"].should == c.name
      resp["domain"].should == c.full_domain
      resp["slogan"].should == c.slogan
      resp["description"].should == c.description
      resp["custom_color1"].should == c.custom_color1
      resp["custom_color2"].should == c.custom_color2
      resp["service_name"].should == "Sharetribe"
      resp["location"].should_not be_nil
      resp["location"]["address"].should == "antarctica"
      resp["service_logo_style"].should == "full-logo"
      
    end
    
    it "returns the custom service_name if that is in use" do
      c = FactoryGirl.create(:community, :settings => {"service_name" => "White Label Co"})
      get :show, :id => c.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["service_name"].should == "White Label Co"
    end
    
    it "returns the categorization used in that community" do
      c = FactoryGirl.create(:community)
      get :show, :id => c.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["categories_tree"].should_not be_nil
      
    end
  end
  
  describe "#classifications" do
    it "returns the translations and price info" do
      c = FactoryGirl.create(:community)
      get :classifications, :id => c.id, :format => :json
      resp = JSON.parse(response.body)
      resp["buy"]["price"].should be_nil
      resp["buy"]["payment"].should_not be_nil
      resp["sell"]["price"].should_not be_nil
      resp["sell"]["price"].should be_true
      resp["rent_out"]["price_quantity_placeholder"].should == "hour, day, week, ..."
      resp["housing"]["translated_name"].should == "spaces"
      resp["housing"]["description"].should == "A space - an apartment, an office or a garden"
      
      
    end
  end

end
