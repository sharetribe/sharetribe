require 'spec_helper'

describe Api::CommunitiesController do
  render_views
    
  describe "#show" do
    it "returns the full JSON of a community" do
      c = FactoryGirl.create(:community)
      l = FactoryGirl.create(:location, :community => c)
      
      get :show, :id => c.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      
      puts resp
      
      resp["id"].should == c.id
      resp["name"].should == c.name
      resp["domain"].should == c.full_domain
      resp["slogan"].should == c.slogan
      resp["description"].should == c.description
      resp["custom_color1"].should == c.custom_color1
      resp["custom_color2"].should == c.custom_color2
      resp["service_name"].should == "Sharetribe"
      resp["location"].should_not be_nil
      
    end
    
    it "returns the custom service_name if that is in use" do
      c = FactoryGirl.create(:community, :settings => {"service_name" => "White Label Co"})
      get :show, :id => c.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["service_name"].should == "White Label Co"
    end
  end

end
