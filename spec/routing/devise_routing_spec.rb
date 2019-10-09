require "spec_helper"

describe "routes for devise", type: :routing do

  it "routes /signup to people controller" do
    expect(get "/signup").to route_to "people#new"
  end

end
