require 'spec_helper'

describe Listing do
  
  before(:each) do
    @listing = FactoryGirl.build(:listing)
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
  
  it "is not valid without category" do
    @listing.category_id = nil
    @listing.should_not be_valid
  end 
  
  it "should not be valid when valid until date is before current date" do
    @listing.valid_until = DateTime.now - 1.day - 1.minute
    @listing.should_not be_valid
  end

  it "should not be valid when valid until is more than one year after current time" do
    @listing.valid_until = DateTime.now + 1.year + 2.days
    @listing.should_not be_valid
  end
  
  context "with listing type 'offer'" do
  
    before(:each) do
      @listing.transaction_type = FactoryGirl.create(:transaction_type_give)
    end
    
    it "should be valid when there is no valid until" do
      @listing.valid_until = nil
      @listing.should be_valid
    end 
  
  end
  
  context "with category 'rideshare'" do
    
    before(:each) do
      @listing.transaction_type = FactoryGirl.create(:transaction_type_give)
      @listing.category = find_or_create_category("rideshare") 
      @listing.origin = "Otaniemi, Espoo"
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
    
    it "should have a title in the form of [ORIGIN]-[DESTINATION]" do    
      @listing.title = "test"
      @listing.should be_valid
      @listing.title.should == "Otaniemi, Espoo - Turku"
    end
    
    it "should not be valid when valid until is less than current time" do
      @listing.valid_until = DateTime.now - 1.hour
      @listing.should_not be_valid
    end
    
    it "should be valid when there is no valid until" do
      @listing.transaction_type = FactoryGirl.create(:transaction_type_give)
      @listing.valid_until = nil
      @listing.should be_valid
    end
  end
  
end 