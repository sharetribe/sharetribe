require 'spec_helper'

describe ApplicationController do 
  
  controller do
    # a mock method to raise the error
    def index
      raise RestClient::Unauthorized
    end 
  end
  
  describe "handling RestClient::Unauthorized exceptions" do
    it "redirects to the home page" do
      get :index
      response.should redirect_to("/?locale=en")
    end
    it "logs the user out from Kassi" do
      get :index
      session[:person_id].should be_nil
      session[:cookie].should be_nil
      assigns("current_user").should be_nil
    end
    it "shows flash error" do
      get :index
      flash[:error].class.should == Array
      flash[:error][0].should eq("error_with_session") 
    end
  end
end