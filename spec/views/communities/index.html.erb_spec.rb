require 'spec_helper'

describe "communities/index.html.erb" do
  before(:each) do
    assign(:communities, [
      stub_model(Community),
      stub_model(Community)
    ])
  end

  it "renders a list of communities" do
    render
  end
end
