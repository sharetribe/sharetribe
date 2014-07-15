require "spec_helper"

describe "Routing for listings" do
  
  it "routes /en/listing_bubble/1 to listings" do
    expect(get "/en/listing_bubble/1").to(
      route_to({ 
                 :controller => "listings",
                 :action => "listing_bubble",
                 :locale => "en",
                 :id => "1"
               }))
  end
  
  it "routes /en/listing_bubble_multiple/1,2 to listings" do
    expect(get "/en/listing_bubble_multiple/1,2").to(
      route_to({ 
                 :controller => "listings",
                 :action => "listing_bubble_multiple",
                 :locale => "en",
                 :ids => "1,2"
               }))
  end

end
