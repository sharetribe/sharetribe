require 'spec_helper'

describe Api::CommentsController do
  render_views
 
    
  before(:each) do
    @c1 = FactoryGirl.create(:community)
    @c2 = FactoryGirl.create(:community)
    @l1 = FactoryGirl.create(:listing, :privacy => "public")
    @l2 = FactoryGirl.create(:listing, :visibility => "this_community")
    @l1.communities = [@c1]
    @l2.communities = [@c2]
    @p1 = FactoryGirl.create(:person)
    @p1.communities << @c1
    @p1.ensure_authentication_token!
  
  end

  describe "create" do
    it "creates a comment to the listing" do
      comments_count = @l1.comments.count
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :content => "This listing is absolutely hilarious", 
                      :listing_id => @l1.id,
                      :community_id => @c1.id,
                      :format => :json
      response.status.should == 201  
      @l1.comments.count.should == comments_count + 1
      #puts response.body
      resp = JSON.parse(response.body)
      resp["listing_id"].should == @l1.id
      resp["author"]["id"].should == @p1.id
      resp["content"].should == "This listing is absolutely hilarious"
    end
    
    it "doesn't create a comment if the listing is not visible to the user" do
      comments_count = @l2.comments.count
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :content => "This listing is should be hidden from me", 
                      :listing_id => @l2.id,
                      :community_id => @c2.id,
                      :format => :json
      response.status.should == 403 
      @l2.comments.count.should == comments_count
      resp = JSON.parse(response.body)
      resp[0].should == "The user doesn't have a permission to see this listing"
    
    end
    
    it "replies with proper error message to a request with wrong listing id" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :content => "This listing is absolutely hilarious", 
                      :listing_id => 999999999,
                      :community_id => @c1.id,
                      :format => :json
      response.status.should == 404
      resp = JSON.parse(response.body)
      resp[0].should == "No listing found with given id"
    end
    
    it "replies with proper error message to a request with wrong community id" do   
      comments_count = @l1.comments.count
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :content => "This listing is strange", 
                      :listing_id => @l1.id,
                      :community_id => 99999999999,
                      :format => :json
      response.status.should == 404
      resp = JSON.parse(response.body)
      resp[0].should == "No community found with given id"
      @l1.comments.count.should == comments_count 
    end
    
    it "replies with proper error message to a request with mistmatching community id" do 
      #listing not visible in community
      @l3 = FactoryGirl.create(:listing, :visibility => "this_community")
      @l3.communities = [@c1]
      comments_count = @l3.comments.count
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      post :create, :content => "This listing is cool", 
                      :listing_id => @l1.id,
                      :community_id => @c2.id,
                      :format => :json
      response.status.should == 400
      resp = JSON.parse(response.body)
      resp[0].should == "This listing is not visible in given community."
      @l3.comments.count.should == comments_count
    end
  end
end