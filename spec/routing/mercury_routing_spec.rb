require "spec_helper"

describe "Routing for mercury", type: :routing do

  it "routes /en/mercury_update to mercury controller" do
    expect(put "/en/mercury_update").to(
      route_to({
                 :controller => "mercury_update",
                 :action => "update",
                 :locale => "en"
               }))
  end

end
