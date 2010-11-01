require 'spec_helper'

describe BadgeNotification do
  
  before(:each) do
    @badge_notification = Factory.build(:badge_notification)
  end
  
  it "is valid with valid attributes" do
    @badge_notification.should be_valid
  end
  
end
