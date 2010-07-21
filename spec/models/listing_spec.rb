require 'spec_helper'

describe Listing do
  
  before(:each) do
    @listing = Listing.new(
      :title => "Test",
      :author_id => 1,
      :listing_type => "request"
    )
  end  
  
  it "is valid with valid attributes" do
    @listing.should be_valid
  end  
  
  it "is not valid without a title" do
    @listing.title = nil 
    @listing.should_not be_valid
  end
  
  it "is not valid without an author id" do
    @listing.author_id = nil
    @listing.should_not be_valid
  end
  
  it "is not valid without listing type" do
    @listing.listing_type = nil
    @listing.should_not be_valid
  end
  
  it "is only valid if listing type is 'request' or 'offer'" do
    @listing.listing_type = "test"
    @listing.should_not be_valid
    @listing.listing_type = "offer"
    @listing.should be_valid
  end
  
end