require "spec_helper"

describe "legacy URL redirection", type: :request do

  before(:each) do
    @person = FactoryGirl.create(:person)
    @community = FactoryGirl.create(:community, :domain => "market.custom.org", use_domain: true)
  end

  it "redirects /people/:id to /:username" do
    get "/people/#{@person.id}"
    expect(response).to redirect_to "/#{@person.username}"
  end

  it "redirects /people/:id/settings to /:username/settings" do
    get "/people/#{@person.id}/settings"
    expect(response).to redirect_to "/#{@person.username}/settings"
  end

  it "redirects /en/people/:id/settings to /:username/settings" do
    get "/en/people/#{@person.id}/settings"
    expect(response).to redirect_to "/en/#{@person.username}/settings"
  end

  it "doesn't redirect /people/incorrect_id" do
    get "http://market.custom.org/people/incorrect_id"
    expect(response.code).to eq "404"
  end

end
