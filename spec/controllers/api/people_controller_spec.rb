require 'spec_helper'

describe Api::PeopleController do
  if not use_asi? # No need to run the API tests with ASI
    describe "show" do
    
      before(:each) do
        @p1 = FactoryGirl.create(:person, :given_name => "Danny", :family_name => "van Testburg")
        @c1 = FactoryGirl.create(:community)
        @c2 = FactoryGirl.create(:community)
        @p1.communities << @c1
        @p1.communities << @c2
        @p1.ensure_authentication_token!
      end
    
      it "returns basic json of a person" do
        get :show, :id => @p1.id, :format => :json
        resp = JSON.parse(response.body)
        response.status.should == 200
        #puts resp.to_yaml
        resp["given_name"].should == "Danny"
        resp["family_name"].should == "van Testburg"
        resp["id"].should == @p1.id
      end
      
      it "includes email if the person asks his own details" do
        request.env['Sharetribe-API-Token'] = @p1.authentication_token
        get :show, :id => @p1.id, :format => :json
        response.status.should == 200
        resp = JSON.parse(response.body)
        #puts resp.to_yaml
        resp["id"].should == @p1.id
        resp["email"].should == @p1.email
      end
    end
  end
end