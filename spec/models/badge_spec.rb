require 'spec_helper'

describe Badge do
  
  before(:each) do
    @badge = Factory.build(:badge)
  end
  
  it "is valid with valid attributes" do
    @badge.should be_valid
  end
  
  it "is not valid without name" do
    @badge.name = nil
    @badge.should_not be_valid
  end
  
  it "is not valid if the person already has the same badge" do
    @badge1 = Factory(:badge)
    @badge2 = Factory.build(:badge)
    @badge2.should_not be_valid
  end
  
end
