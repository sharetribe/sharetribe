require 'spec_helper'

describe SettingsController do
  fixtures :communities

  describe "#unsubscribe" do
    
    it "should unsubscribe the user from the email specified in parameters" do
      @request.host = "test.lvh.me"
      p1 , session = get_test_person_and_session
      Community.first.members << p1
      sign_in_for_spec(p1)
      
      p1.set_default_preferences
      
      
      p1.preferences["email_about_weekly_events"].should be_true
      get :unsubscribe, {:email_type => "community_updates", :person_id => p1.id}
      response.status.should == 200
      #p1 = Person.find(p1.id) #search again to refresh
      p1.preferences["email_about_weekly_events"].should be_false
      
    end
    
    it "should unsubscribe even if auth token is expired" do
      
    end
    
    it "should not unsubscribe if no token provided" do
      
    end
  end
end
