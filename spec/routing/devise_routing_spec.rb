require "spec_helper"

describe "routes for devise", type: :routing do

  it "routes /signup to people controller" do
    expect(get "/signup").to route_to "people#new"
  end

  it "routes /people/auth/facebook/setup to sessions controller" do
    expect(get "/people/auth/facebook/setup").to(
      route_to({
                 :controller => "sessions",
                 :action => "facebook_setup",
                 :provider => "facebook"
               })
    )
  end

end
