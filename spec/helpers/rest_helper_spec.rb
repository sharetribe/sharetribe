require 'spec_helper'

describe RestHelper do
  
  context "Session is no more valid" do
    context "Kassi-cookie is invalid" do
      it "should create new Kassi-cookie and repeat the request" do
        @test_person, @session = get_test_person_and_session
        
        # Generate a cookie and make it look like it would have been the Kassi-cookie stored in cache
        #cookie = Session.kassi_cookie
        cookie = {"_trunk_session" => "NotAVeryValidCookie_JustForTesting"}
        Session.set_kassi_cookie(cookie)
        Session.kassi_cookie.should == cookie
        
        response = RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{@test_person.id}/@self", {:cookies => cookie})
        
        #The Kassi-cookie should now been noted as invalid and renewed
        new_cookie = Session.kassi_cookie
        new_cookie.should_not == cookie
        
        #The new cookie should still be valid and return same as the first request did (when it tried again in resthelper)
        response2 = RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/#{@test_person.id}/@self", {:cookies => new_cookie})
        response2.should == response
      end
    end
    
    context "user-session cookie is invalid" do     
      it "should raise unauthorized error" do
        @test_person, @session = get_test_person_and_session
        cookie = @session.cookie
        @session.destroy #logout to make the cookie invalid
        lambda {
          response = RestHelper.make_request(:get, "#{APP_CONFIG.asi_url}/people/anyID/@self", {:cookies => cookie})
        }.should raise_error(RestClient::Unauthorized)
      end
    end
  end
end