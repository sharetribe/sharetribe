require 'spec_helper'

describe Message do

  before(:each) do
    @message = FactoryGirl.build(:message)
  end

  it "is valid with valid attributes" do
    @message.should be_valid
  end

  it "is not valid with both content and action missing" do
    @message.content = nil
    @message.should_not be_valid
    @message.content = ""
    @message.should_not be_valid
    @message.action = ""
    @message.should_not be_valid
    @message.action = "accept"
    @message.should be_valid
    @message.action = nil
    @message.content = "test"
    @message.should be_valid
  end

  it "is not valid without sender" do
    @message.sender = nil
    @message.should_not be_valid
  end

end
