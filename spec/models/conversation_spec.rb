require 'spec_helper'

describe Conversation do

  before(:each) do
    @conversation = FactoryGirl.build(:conversation)
  end

  it "should be valid with valid attributes" do
    @conversation.should be_valid
  end

  it "should not be valid without a title" do
    @conversation.title = nil
    @conversation.should_not be_valid
  end

  it "should be valid without a listing" do
    @conversation.listing = nil
    @conversation.should be_valid
  end

  it "should not be valid with a too long title" do
    @conversation.title = "a" * 121
    @conversation.should_not be_valid
  end
end
