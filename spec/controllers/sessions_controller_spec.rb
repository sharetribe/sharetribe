require 'spec_helper'



describe SessionsController, "POST create" do
  fixtures :people, :communities, :community_memberships

  it "redirects back to original community's domain" do
    @request.host = "test.lvh.me"
    post :create, {:person  => {:login => "kassi_testperson1", :password => "testi"}, :community => "test"}
    response.should redirect_to "http://test.lvh.me:9887/?locale=en"
  end  
end
