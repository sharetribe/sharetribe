# encoding: UTF-8

require 'spec_helper'

describe Api::ListingsController do
  render_views
  
    
  before(:each) do
    Listing.all.collect(&:destroy) # for some reason there's a listing before starting. Destroy to be clear.
  
    @c1 = FactoryGirl.create(:community)
    @c2 = FactoryGirl.create(:community)
    
    @p1 = FactoryGirl.create(:person)
    @p1.communities << @c1
    @p1.ensure_authentication_token!
    
    @l1 = FactoryGirl.create(:listing, :listing_type => "request", :title => "bike", :description => "A very nice bike", :created_at => 3.days.ago, :author => @p1)
    @l1.communities = [@c1]
    FactoryGirl.create(:listing, :listing_type => "offer", :title => "hammer", :created_at => 2.days.ago, :description => "<b>shiny</b> new hammer, see details at http://en.wikipedia.org/wiki/MC_Hammer", :share_type => "sell").communities = [@c1]
    FactoryGirl.create(:listing, :listing_type => "request", :title => "help me", :created_at => 12.days.ago).communities = [@c2]
    FactoryGirl.create(:listing, :listing_type => "request", :title => "old junk", :open => false, :description => "This should be closed already, but nice stuff anyway").communities = [@c1]
    @l4 = FactoryGirl.create(:listing, :listing_type => "request", :title => "car", :created_at => 2.months.ago, :description => "I needed a car earlier, but now this listing is no more open", :share_type => "borrow")
    @l4.communities = [@c1]
    @l4.update_attribute(:valid_until, 2.days.ago)

  
  end


  describe "index" do
  
    it "requires valid community_id" do
      get :index, :format => :json
      response.status.should == 400
      resp = JSON.parse(response.body)
      resp[0].should =~ /Community must be selected./
    end
    
    it "returns open listings if called without extra parameters, (paginated by 50)" do
      get :index, :community_id => @c1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 2
      resp["page"].should == 1
      resp["per_page"].should == 50
      resp["total_pages"].should == 1
    end
  
    it "supports community_id and type as parameters" do
      get :index, :community_id => @c1.id, :format => :json
      resp = JSON.parse(response.body)
      response.status.should == 200
      resp["listings"].count.should == 2
    
      get :index, :community_id => @c2.id, :format => :json
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
    
      get :index, :community_id => @c1.id, :listing_type => "offer", :format => :json
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
    
      get :index, :community_id => @c2.id, :listing_type => "offer", :format => :json
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 0
    
      get :index, :community_id => @c1.id, :listing_type => "request", :format => :json
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
    end
  
    it "uses status parameter with default: 'open'" do
      get :index, :community_id => @c1.id, :format => :json
      resp = JSON.parse(response.body)
      response.status.should == 200
      resp["listings"].count.should == 2
    
      get :index, :community_id => @c1.id, :status => "open", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 2
    
      get :index, :community_id => @c1.id, :status => "closed", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
    
      get :index, :community_id => @c1.id, :status => "all", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 4
    
    end
  
    it "returns an array of lisitings with correct attributes" do
      get :index, :community_id => @c1.id, :listing_type => "offer", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
      resp["listings"][0]["title"].should == "hammer"
      resp["listings"][0]["description"].should =~ /<b>shiny<\/b> new hammer/
    end
  
    it "supports pagination" do
      get :index, :community_id => @c1.id, :per_page => 2, :status => "all", :page => 1, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      #puts resp.to_yaml
      resp["listings"].count.should == 2
      resp["listings"][0]["title"].should == "old junk"
      resp["listings"][1]["title"].should == "hammer"
      resp["total_pages"].should == 2
    
      get :index, :community_id => @c1.id, :per_page => 2, :page => 2, :status => "all", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      #puts resp.to_yaml
      resp["listings"].count.should == 2
      resp["listings"][0]["title"].should == "bike"
      resp["total_pages"].should == 2
    end

    # Not in use as not yet set up Sphinx for RSpec
    
    # it "supports search" do
    #    get :index, :community_id => @c1.id, :search => "nice", :format => :json
    #    response.status.should == 200
    #    resp = JSON.parse(response.body)
    #    puts resp.to_yaml
    #  end
    
    it "can return listings for single person only" do
      get :index, :community_id => @c1.id, :person_id => @p1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["listings"].count.should == 1
      resp["listings"][0]["title"]. should == "bike"
    end
  end

  describe "show" do
    it "returns one listing" do
      get :show, :id => @l1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["title"].should == "bike"
      resp["description"].should == "A very nice bike"
      #puts resp.to_yaml
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
                    :valid_until => 2.months.from_now,
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
      resp["valid_until"].to_date.should == 2.months.from_now.to_date
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
    
    it "supports image upload" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :title => "nice looking offer", 
                    :description => "Testing photo upload", 
                    :listing_type => "offer",
                    :category => "item",
                    :share_type => "sell",
                    :visibility => "this_community",
                    :community_id => @c1.id,
                    :image => Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/Australian_painted_lady.jpg"),"image/jpeg"),
                    :format => :json
      
      #puts response.body.inspect              
      response.status.should == 201
      resp = JSON.parse(response.body)
      #puts resp.to_yaml
      resp["image_urls"][0].should  match /Australian_painted_lady.jpg/
      
    end
    
    describe "locations" do
      
   
      it "supports setting locations by coordinates" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :create, :title => "hammer", 
                      :description => "well located hammer", 
                      :listing_type => "offer",
                      :category => "item",
                      :share_type => "sell",
                      :visibility => "this_community",
                      :community_id => @c1.id,
                      :latitude => "60.2426",
                      :longitude => "25.0475",
                      #:address => "helsinki",
                      :format => :json
      
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        response.status.should == 201
        # puts Location.last.to_yaml
        # puts Location.count
        Location.count.should == 1
        Listing.last.origin_loc.latitude.should == 60.2426
      end
    
      it "supports setting also destination location for rideshare listings" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        post :create, :title => "Ride in Finland", 
                      :description => "Join the road trip", 
                      :listing_type => "offer",
                      :category => "rideshare",
                      :visibility => "this_community",
                      :community_id => @c1.id,
                      :valid_until => 2.days.from_now,
                      :latitude => "62.2426",
                      :longitude => "25.7475",
                      :destination_latitude => "61.2426",
                      :destination_longitude => "26.7475",
                      :destination  => "office",
                      :address => "helsinki",
                      :origin => "Home",
                      :format => :json
      
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        response.status.should == 201
        #puts Location.last.to_yaml
        Location.count.should == 2
        #puts "hox #{Listing.last.inspect}"
        Listing.last.origin_loc.latitude.should == 62.2426
        Listing.last.destination_loc.longitude.should == 26.7475
        Listing.last.destination.should == "office"
        Listing.last.origin_loc.address.should == "helsinki"
        Listing.last.valid_until.should be_within(3.seconds).of(2.days.from_now)
      end
      
      it "supports setting locations by address only" do

      end
    end
  end
  
  describe "ATOM feed" do
    it "lists the most recent listings in order" do
      get :index, :community_id => @c1.id, :format => :atom
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.at('feed/logo').text.should == "https://www.sharetribe.com/assets/dashboard/sharetribe_logo.png"
      
      doc.at("feed/title").text.should =~ /Listings in sharetribe_testcommunity_\d+ Sharetribe/
      doc.search("feed/entry").count.should == 2
      doc.search("feed/entry/title")[0].text.should == "Selling: hammer"
      doc.search("feed/entry/title")[1].text.should == "Buying: bike"
      doc.search("feed/entry/published")[0].text.should > doc.search("feed/entry/published")[1].text
      #DateTime.parse(doc.search("feed/entry/published")[1].text).should == @l1.created_at
      doc.search("feed/entry/content")[1].text.should =~ /#{@l1.description}/
    end
    
    
    it "supports localization" do
      get :index, :community_id => @c1.id, :format => :atom, :locale => "fi"
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)

      doc.at("feed/title").text.should =~ /Ilmoitukset sharetribe_testcommunity_\d+-Sharetribessa/
      doc.at("feed/entry/title").text.should == "Myydään: hammer"
      doc.at("feed/entry/category").attribute("label").value.should == "Tavarat"       
    end
  
    it "supports fliter parameters" do
      get :index, :community_id => @c1.id, :format => :atom, :listing_type => "request", :locale => "en"
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.search("feed/entry").count.should == 1
      doc.at("feed/entry/title").text.should == "Buying: bike"
    end
    
    it "escapes html tags, but adds links" do
      get :index, :community_id => @c1.id, :format => :atom
      response.status.should == 200
      doc = Nokogiri::XML::Document.parse(response.body)
      doc.at("feed/entry/content").text.should =~ /&lt;b&gt;shiny&lt;\/b&gt; new hammer, see details at <a href="http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer">http:\/\/en\.wikipedia\.org\/wiki\/MC_Hammer<\/a>/
    end

    # TODO: fix search tests after sphinx upgraded (or changed)
    # it "supports search" do
    #   get :index, :community_id => @c1.id, :format => :atom, :search => "hammer"
    #   response.status.should == 200
    #   doc = Nokogiri::XML::Document.parse(response.body)
    #   doc.search("feed/entry").count.should == 1
    #   doc.at("feed/entry/title").text.should == "Selling: hammer"
    # end
  
  end
end