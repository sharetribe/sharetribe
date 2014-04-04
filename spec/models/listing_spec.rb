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
end
