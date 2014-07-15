require "spec_helper"

describe "Routing for mercury" do
  
  it "routes /en/mercury_update to mercury controller" do
    expect(put "/en/mercury_update").to(
      route_to({ 
                 :controller => "mercury_update", 
                 :action => "update",
                 :method => :put,
                 :locale => "en"
               }))
  end

end
