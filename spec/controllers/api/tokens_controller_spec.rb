require 'spec_helper'

describe Api::TokensController do
  render_views
  
  if not use_asi? # No need to run the API tests with ASI
    describe "show" do
    
      before(:each) do
        @p1 = FactoryGirl.create(:person, :password => "test1234", :username => "jack")
      end
    
      it "returns basic json for a token, which includes the person" do
        post :create, :username => "jack", :password => "test1234", :format => :json
        resp = JSON.parse(response.body)
        #puts response.body
      end
    end
  end
end