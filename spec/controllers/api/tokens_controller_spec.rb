require 'spec_helper'

describe Api::TokensController do
  render_views

  before(:each) do
    pending("API tests are pending")
  end
  

  describe "show" do
  
    before(:each) do
      @p1 = FactoryGirl.create(:person, :password => "test1234", :username => "jack", :emails => [ FactoryGirl.create(:email, :address => "jack@example.com") ])
      @p1.ensure_authentication_token!
    end
  
    it "returns basic json for a token, which includes the person" do
      post :create, :login => "jack", :password => "test1234", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["api_token"].should == @p1.authentication_token
      resp["person"]["id"].should == @p1.id
    end
    
    it "allows logging in with email too" do
      post :create, :login => "jack@example.com", :password => "test1234", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["api_token"].should == @p1.authentication_token
      resp["person"]["id"].should == @p1.id
    end
    
    it "allows logging in with old username parameter too" do
      post :create, :username => "jack", :password => "test1234", :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["api_token"].should == @p1.authentication_token
      resp["person"]["id"].should == @p1.id
    end
  end

end