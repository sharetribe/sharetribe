require 'spec_helper'

describe "communities/new.html.erb" do
  before(:each) do
    assign(:community, stub_model(Community,
      :new_record? => true
    ))
  end

  it "renders new community form" do
    render

    rendered.should have_selector("form", :action => communities_path, :method => "post") do |form|
    end
  end
end
