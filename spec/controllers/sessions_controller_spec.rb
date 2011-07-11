require 'spec_helper'



describe SessionsController, "POST create" do
  fixtures :people, :communities, :community_memberships
  
  #before (:each) {set_subdomain("login")}  
  
  it "creates a Session model" do
    @request.host = "login.lvh.me"
    post :create, {:username => "kassi_testperson1", :password => "testi", :community => "test"}
    assigns["session"].should_not be_nil
    assigns["session"].person_id.should_not be_nil
    
  end
  
  it "stores person_id to session if logged succesfully" do
    @request.host = "login.lvh.me"
    post :create, {:username => "kassi_testperson1", :password => "testi", :community => "test"}
    session["person_id"].should_not be_blank
    session["person_id"].should equal(assigns["session"].person_id)
  end
  
  it "redirects back to original community's domain" do
    @request.host = "login.lvh.me"
    post :create, {:username => "kassi_testperson1", :password => "testi", :community => "test"}
    response.should redirect_to "http://test.lvh.me/?locale=en"
  end
    
  
end
