require 'spec_helper'



describe SessionsController, "POST create" do
  fixtures :people, :communities
  
  before (:each) {set_subdomain("login")}  
  
  it "creates a Session model" do
    #Session.should_receive(:create)
    post :create, {:username => "kassi_testperson1", :password => "testi"}
    assigns["session"].should_not be_nil
    assigns["session"].person_id.should_not be_nil
    
  end
  
  it "stores person_id to session if logged succesfully" do
    post :create, {:username => "kassi_testperson1", :password => "testi"}
    session["person_id"].should_not be_blank
    session["person_id"].should equal(assigns["session"].person_id)
  end
    
  
end
