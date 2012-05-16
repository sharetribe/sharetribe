require 'spec_helper'

describe "communities/edit.html.erb" do
  before(:each) do
    @community = assign(:community, stub_model(Community,
      :new_record? => false
    ))
  end

  it "renders the edit community form" do
    render

    rendered.should have_selector("form", :action => community_path(@community), :method => "post") do |form|
    end
  end
end
