require 'spec_helper'

describe ApplicationController do 
  #before (:each) {set_subdomain}
  
  controller do
    # a mock method to be able to call index without route
    def index
      # do nothing as we are testing the filters here only
    end 
  end

  
  describe "handling RestClient::Unauthorized exceptions" do
    
    controller do
      # a mock method to raise the error
      def index
        raise RestClient::Unauthorized
      end 
    end
    
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
      @request.host = "login.lvh.me"
      request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
      get :index
      flash[:error].class.should == Array
      flash[:error][0].should eq("error_with_session") 
    end
  end
  
  describe "handling wrong requests coming to login domain" do
    
    controller do
      # a mock method to be able to call index without route
      def index
        # do nothing as we are testing the filters here only
      end 
    end
    
    describe "HTTP_REFERER is blank" do
      
      it "shows error an page" do
        request.host = "login.lvh.me"
        request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
        get :index
        response.should render_template("public/501.html")
      end
      
      it "redirects to aalto community if longer request path (to keep legacy email links working)" do
        request.host = "login.lvh.me"
        request.env['HTTP_REFERER'] = request.env['HTTP_ORIGIN'] = ''
        request.env['REQUEST_PATH'] = '/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42'
        get :index
        response.should redirect_to("http://aalto.kassi.eu/en/people/s0m3Gu1dr4nd0mn3ss/messages/received/42")
      end
      
    end
    
    describe "HTTP_REFERER is known but action is wrong for login domain" do
      
      it "redirects back to the referer domain and shows error" do
        request.host = "login.lvh.me"
        request.env['HTTP_REFERER'] = 'http://test.lvh.me:9887'
        request.env['HTTP_ORIGIN'] = ''
        get :index
        response.should redirect_to("http://test.lvh.me:9887/en")
        flash[:error].class.should == Array
        flash[:error][0].should eq("error_with_session")
      end
    end
    
  end
  
end