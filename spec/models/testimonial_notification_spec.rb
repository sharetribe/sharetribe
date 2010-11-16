require 'spec_helper'

describe TestimonialNotification do
  
  before(:each) do
    @testimonial_notification = Factory.build(:testimonial_notification)
  end
  
  it "is valid with valid attributes" do
    @testimonial_notification.should be_valid
  end
  
end
