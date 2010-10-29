require 'spec_helper'

describe Notification do
  
  before(:each) do
    @notification = Factory.build(:notification)
  end
  
  it "is valid with valid attributes" do
    @notification.should be_valid
  end
  
end
