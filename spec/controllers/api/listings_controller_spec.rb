require 'spec_helper'

describe Api::ListingsController do

  describe "index" do
    
    before(:each) do
      @c1 = FactoryGirl.create(:community)
      @c2 = FactoryGirl.create(:community)
      FactoryGirl.create(:listing, :listing_type => "request").communities = [@c1]
      FactoryGirl.create(:listing, :listing_type => "offer", :share_type => "sell").communities = [@c1]
      FactoryGirl.create(:listing, :listing_type => "request").communities = [@c2]
      FactoryGirl.create(:listing, :listing_type => "request", :status => "closed").communities = [@c1]
    end
    
    it "returns all listings if called without parameters" do
      get :index, :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 3
    end
    
    it "supports community_id and type as parameters" do
      get :index, :community_id => @c1.id, :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 2
      
      get :index, :community_id => @c2.id, :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get :index, :community_id => @c1.id, :type => "offer", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get :index, :community_id => @c2.id, :type => "offer", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 0
      
      get :index, :type => "request", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 2
    end
    
    it "uses status parameter with default: 'open'" do
      get :index, :community_id => @c1.id, :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 2
      
      get :index, :community_id => @c1.id, :status => "open", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 2
      
      get :index, :community_id => @c1.id, :status => "closed", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get :index, :community_id => @c1.id, :status => "all", :format => :json
      resp = JSON.parse(response.body)
      resp.count.should == 3
      
    end
    
    it "returns an array of lisitings with correct attributes" do
      get :index, :type => "offer", :format => :json
      resp = JSON.parse(response.body)
      #resp.count.should == 1
      puts resp[0]["listing"].to_yaml
    end
  end
end