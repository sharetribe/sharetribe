require 'spec_helper'

describe Api::DevicesController do
  render_views

  before(:each) do
    pending("API tests are pending")
    @p1 = FactoryGirl.create(:person, :given_name => "Danny", :family_name => "van Testburg")
    @p1.ensure_authentication_token!
  end

  describe "index" do
    it "shows the list of user's devices" do
      @d1 = FactoryGirl.create(:device, :person => @p1)
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      get :index, :person_id => @p1.id, :format => :json
      response.status.should == 200
      #puts response.body
      resp = JSON.parse(response.body)
      #puts resp.to_yaml
      resp[0]["device_type"].should == "iPhone"
      resp[0]["device_token"].should == "LSIDFSLDJIOGSSCSBEUS52349583"
    end
  
  end

  describe "post" do
    it "adds a device to the user" do
      request.env['Sharetribe-API-Token'] = @p1.authentication_token
      @p1.devices.count.should == 0
      post :create, :person_id => @p1.id, :device_type => "iPad", :device_token => "738SDK2FFKD29D", :format => :json
      #puts response.body
      resp = JSON.parse(response.body)
      response.status.should == 201
      #puts resp.to_yaml
      resp["device_type"].should == "iPad"
      resp["device_token"].should == "738SDK2FFKD29D"
    
      @p1.devices.count.should == 1
      @p1.devices.last.device_token.should == "738SDK2FFKD29D"
    end
  end

end
