require 'spec_helper'

describe Listing do
  
  before(:each) do
    @listing = Listing.new(
      :title => "Test",
      :description => "0" * 4000,
      :author_id => 1,
      :listing_type => "request",
      :category => "item",
      :share_type => ["buy", "borrow"]
    )
  end  
  
  it "is valid with valid attributes" do
    @listing.should be_valid
  end  
  
  it "is not valid without a title" do
    @listing.title = nil 
    @listing.should_not be_valid
  end
  
  it "is not valid with a too short title" do
    @listing.title = "a" 
    @listing.should_not be_valid
  end
  
  it "is not valid with a too long title" do
    @listing.title = "0" * 101 
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
      @listing.share_type = Listing::VALID_SHARE_TYPES[@listing.listing_type][@listing.category]
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
    Listing::VALID_CATEGORIES.reject { |c| c.eql?("rideshare") }.each do |category| 
      @listing.category = category
      @listing.share_type = Listing::VALID_SHARE_TYPES[@listing.listing_type][@listing.category]
      @listing.should be_valid
    end  
  end
  
  it "is only valid if the transaction type corresponds with the category" do
    @listing.share_type = nil
    @listing.should_not be_valid
    Listing::VALID_CATEGORIES.each { |c| listing_is_valid_with_correct_share_type("offer", c) }
    Listing::VALID_CATEGORIES.each { |c| listing_is_valid_with_correct_share_type("request", c) }
    [
      ["request", "item", ["test"]],
      ["request", "item", ["buy", "test"]],
      ["request", "item", ["sell"]],
      ["request", "item", ["buy", "sell"]],
      ["request", "favor", ["buy", "borrow"]],
      ["request", "rideshare", ["sell"]],
      ["request", "housing", ["test"]],
      ["request", "housing", ["buy", "test"]],
      ["request", "housing", ["borrow"]],
      ["request", "housing", ["sell"]],
      ["request", "housing", ["buy", "sell"]],
      ["offer", "item", ["test"]],
      ["offer", "item", ["sell", "test"]],
      ["offer", "item", ["buy"]],
      ["offer", "item", ["buy", "sell"]],
      ["offer", "housing", ["test"]],
      ["offer", "housing", ["sell", "test"]],
      ["offer", "housing", ["lend"]],
      ["offer", "housing", ["lend", "sell"]]
    ].each { |array| listing_is_not_valid_with_incorrect_share_type(array[0], array[1], array[2]) }
  end
  
  context "with category 'rideshare'" do
    
    before(:each) do
      @listing.share_type = nil
      @listing.category = "rideshare"
      @listing.origin = "Otaniemi"
      @listing.destination = "Turku"
    end  
    
    it "is valid with valid origin and destination" do
      @listing.should be_valid
    end
    
    it "is not valid without origin" do
      @listing.origin = nil
      @listing.should_not be_valid
    end
    
    it "is not valid without destination" do
      @listing.destination = nil
      @listing.should_not be_valid
    end
    
    it "is not valid with a too short origin" do
      @listing.origin = "a"
      @listing.should_not be_valid
    end
    
    it "is not valid with a too long origin" do
      @listing.origin = "a" * 49
      @listing.should_not be_valid
    end
    
    it "is not valid with a too short destination" do
      @listing.destination = "a"
      @listing.should_not be_valid
    end
    
    it "is not valid with a too long destination" do
      @listing.destination = "a" * 51
      @listing.should_not be_valid
    end
    
    it "is not valid with share type" do
      @listing.share_type = ["buy"]
      @listing.should_not be_valid
    end  
    
    it "should have a title in the form of [ORIGIN]-[DESTINATION]" do    
      @listing.title = "test"
      @listing.should be_valid
      @listing.title.should == "Otaniemi - Turku"
    end
  
  end
  
  private
  
  def listing_is_valid_with_correct_share_type(listing_type, category)
    @listing.listing_type = listing_type
    @listing.category = category
    @listing.share_type = []
    if Listing::VALID_SHARE_TYPES[listing_type][category]
      Listing::VALID_SHARE_TYPES[listing_type][category].each_with_index do |share_type, index|
        @listing.share_type[index] = share_type
        @listing.should be_valid
      end
    end  
  end
  
  def listing_is_not_valid_with_incorrect_share_type(listing_type, category, share_types)
    @listing.listing_type = listing_type
    @listing.category = category
    @listing.share_type = []
    share_types.each_with_index do |type, index|
      @listing.share_type[index] = type
    end
    @listing.should_not be_valid
  end
  
end 