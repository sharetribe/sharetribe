require 'spec_helper'

describe SettingsController do
  fixtures :communities

  describe "#unsubscribe" do
    
    it "should unsubscribe the user from the email specified in parameters" do
      @request.host = "test.lvh.me"
      p1 , session = get_test_person_and_session
      sign_in_for_spec(p1)
      
      p1.set_default_preferences
      
      
      p1.min_days_between_community_updates.should == 1
      get :unsubscribe, {:email_type => "community_updates", :person_id => p1.id}
      response.status.should == 200
      p1.min_days_between_community_updates.should == 100000
      #response.body.should include("Unsubscribe succesful")
      
    end
    
    it "should unsubscribe even if auth token is expired" do
      @request.host = "test.lvh.me"
      p1 = FactoryGirl.create(:person)
      t = p1.new_email_auth_token
      AuthToken.find_by_token(t).update_attribute(:expires_at, 2.days.ago)
      p1.set_default_preferences
      p1.min_days_between_community_updates.should == 1
      get :unsubscribe, {:email_type => "community_updates", :person_id => p1.id, :auth => t}
      response.status.should == 302 #redirection to url withouth token in query string
      session[:expired_auth_token].should == t
      get :unsubscribe, {:email_type => "community_updates", :person_id => p1.id}, 
                        {:expired_auth_token => t}
      response.status.should == 200
      p1 = Person.find(p1.id) # fetch again to refresh
      p1.min_days_between_community_updates.should == 100000
    end
    
    it "should not unsubscribe if no token provided" do
      @request.host = "test.lvh.me"
      p1 = FactoryGirl.create(:person)
      p1.set_default_preferences
      p1.min_days_between_community_updates.should == 1
      get :unsubscribe, {:email_type => "community_updates", :person_id => p1.id}
      response.status.should == 401
      p1.min_days_between_community_updates.should == 1
      
    end
  end
end
