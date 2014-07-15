require "spec_helper"

describe "legacy URL redirection" do
  
  before(:each) do
    @person = FactoryGirl.create(:person)
    @community = FactoryGirl.create(:community, :domain => "market.custom.org")
  end

  it "redirects /people/:id to /:username" do
    get "/people/#{@person.id}"
    response.should redirect_to "/#{@person.username}"
  end
  
  it "redirects /people/:id/settings to /:username/settings" do
    get "/people/#{@person.id}/settings"
    response.should redirect_to "/#{@person.username}/settings"
  end
  
  it "redirects /en/people/:id/settings to /:username/settings" do
    get "/en/people/#{@person.id}/settings"
    response.should redirect_to "/en/#{@person.username}/settings"
  end

  it "doesn't redirect /people/incorrect_id" do
    get "http://market.custom.org/people/incorrect_id"
    response.code.should eq "404"
  end
  
end
