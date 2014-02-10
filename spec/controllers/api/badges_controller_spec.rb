require 'spec_helper'

describe Api::BadgesController do
  render_views
  
  before(:each) do
    pending("API tests are pending")
    @p1 = FactoryGirl.create(:person)
    @p2 = FactoryGirl.create(:person)
    @t1 = FactoryGirl.create(:badge, :person_id => @p1, :name => "rookie")
    @t2 = FactoryGirl.create(:badge, :person_id => @p1, :name => "volunteer_bronze")
    @t3 = FactoryGirl.create(:badge, :person_id => @p2, :name => "first_transaction")
  end

  describe "index" do
    it "returns one person's badges" do
      get :index, :person_id => @p1.id, :format => :json
      response.status.should == 200
      resp = JSON.parse(response.body)
      resp["badges"].count.should == 2
      resp["badges"][0]["name"].should == "rookie"
      resp["badges"][0]["description"].should == "You have added an offer or a request in Sharetribe for the first time. Here we go!"
      resp["badges"][0]["picture_url"].should match /\/assets\/images\/badges\/rookie_large\.png$/ 
      resp["badges"][1]["name"].should == "volunteer_bronze"
      resp["badges"][1]["description"].should == "You like to put your skills in use by helping others. You have three open service offers in Sharetribe."
      resp["badges"][1]["picture_url"].should match /\/assets\/images\/badges\/volunteer_bronze_large\.png$/
    end
  end

end