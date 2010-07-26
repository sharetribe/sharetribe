require 'spec_helper'

describe Listing do
  
  before(:each) do
    @listing = Listing.new(
      :title => "Test",
      :description => "0" * 4000,
      :author_id => 1,
      :listing_type => "request",
      :category => "item"
    )
  end  
  
  it "is valid with valid attributes" do
    @listing.should be_valid
  end  
  
  it "is not valid without a title" do
    @listing.title = nil 
    @listing.should_not be_valid
  end
  
  it "is valid without a description" do
    @listing.description = nil 
    @listing.should be_valid
  end
  
  it "is not valid if description is longer than 5000 characters" do
    @listing.description = "0" * 5001
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
  
  it "is only valid if listing type is one of the valid types" do
    @listing.listing_type = "test"
    @listing.should_not be_valid
    Listing::VALID_TYPES.each do |type| 
      @listing.listing_type = type
      @listing.should be_valid
    end  
  end
  
  it "is not valid without category" do
    @listing.category = nil
    @listing.should_not be_valid
  end 
  
  it "is only valid if category is one of the valid categories" do
    @listing.category = "test"
    @listing.should_not be_valid
    Listing::VALID_CATEGORIES.each do |category| 
      @listing.category = category
      @listing.should be_valid
    end  
  end 
  
end 