require 'spec_helper'

describe Api::ListingsController do
  if not use_asi? # No need to run the API tests with ASI
      
    before(:each) do
      Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.
    
      @c1 = FactoryGirl.create(:community)
      @c2 = FactoryGirl.create(:community)
      @l1 = FactoryGirl.create(:listing, :listing_type => "request", :title => "bike", :description => "A very nice bike", :created_at => 3.days.ago)
      @l1.communities = [@c1]
      FactoryGirl.create(:listing, :listing_type => "offer", :title => "hammer", :description => "shiny new hammer", :share_type => "sell").communities = [@c1]
      FactoryGirl.create(:listing, :listing_type => "request", :title => "help me", :created_at => 12.days.ago).communities = [@c2]
      FactoryGirl.create(:listing, :listing_type => "request", :title => "old junk", :open => false, :description => "This should be closed already").communities = [@c1]
    
      @p1 = FactoryGirl.create(:person)
      @p1.communities << @c1
      @p1.ensure_authentication_token!
    
    end
  

    describe "index" do
    
      it "returns open listings if called without parameters, (paginated by 50)" do
        get :index, :format => :json
        resp = JSON.parse(response.body)
        #puts resp.inspect
        resp.count.should == 3
        # TODO test default pagination
      end
    
      it "supports community_id and type as parameters" do
        get :index, :community_id => @c1.id, :format => :json
        resp = JSON.parse(response.body)
        response.status.should == 200
        resp.count.should == 2
      
        get :index, :community_id => @c2.id, :format => :json
        resp = JSON.parse(response.body)
        resp.count.should == 1
      
        get :index, :community_id => @c1.id, :listing_type => "offer", :format => :json
        resp = JSON.parse(response.body)
        resp.count.should == 1
      
        get :index, :community_id => @c2.id, :listing_type => "offer", :format => :json
        resp = JSON.parse(response.body)
        resp.count.should == 0
      
        get :index, :listing_type => "request", :format => :json
        resp = JSON.parse(response.body)
        resp.count.should == 2
      end
    
      it "uses status parameter with default: 'open'" do
        get :index, :community_id => @c1.id, :format => :json
        resp = JSON.parse(response.body)
        response.status.should == 200
        resp.count.should == 2
      
        get :index, :community_id => @c1.id, :status => "open", :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        resp.count.should == 2
      
        get :index, :community_id => @c1.id, :status => "closed", :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        resp.count.should == 1
      
        get :index, :community_id => @c1.id, :status => "all", :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        resp.count.should == 3
      
      end
    
      it "returns an array of lisitings with correct attributes" do
        get :index, :listing_type => "offer", :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        resp.count.should == 1
        resp[0]["title"].should == "hammer"
        resp[0]["description"].should == "shiny new hammer"
      end
    
      it "supports pagination" do
        get :index, :per_page => 2, :page => 1, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        resp.count.should == 2
        resp[0]["title"].should == "hammer"
        resp[1]["title"].should == "bike"
      
        get :index, :per_page => 2, :page => 2, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        resp.count.should == 1
        resp[0]["title"].should == "help me"
      
      end
    end
  
    describe "show" do
      it "returns one listing" do
        get :show, :id => @l1.id, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        resp["title"].should == "bike"
        resp["description"].should == "A very nice bike"
        #puts resp.inspect    
      end
    end
  
    describe "create" do
      it "creates a new listing" do
        listings_count = Listing.count
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :create, :title => "new great listing", 
                      :description => "This is what you need!", 
                      :listing_type => "offer",
                      :category => "item",
                      :share_type => "sell",
                      :visibility => "this_community",
                      :community_id => @c1.id,
                      :format => :json
        response.status.should == 201
        Listing.count.should == listings_count + 1
        resp = JSON.parse(response.body)
        resp["title"].should == "new great listing"
        resp["description"].should == "This is what you need!"
        resp["visibility"].should == "this_community"
        resp["share_type"].should == "sell"
        resp["category"].should == "item"
        resp["listing_type"].should == "offer"
        resp["author"]["id"].should == @p1.id
      end
    
      it "gives informative error messages" do
        listings_count = Listing.count
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :create, :description => "This is what you need!", 
                      :listing_type => "offer",
                      :share_type => "sell",
                      :visibility => "this_community",
                      :community_id => @c1.id,
                      :format => :json
        response.status.should == 400
        Listing.count.should == listings_count
        resp = JSON.parse(response.body)
        #puts resp.inspect
        resp[0].should match /Title is too short/
        resp[1].should match /Category is not included in the list/
      end
    end
  end
end