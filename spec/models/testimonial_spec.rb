require 'spec_helper'

describe Testimonial do
  
  before(:each) do
    @testimonial = Factory.build(:testimonial)
  end
  
  it "is valid with valid attributes" do
    @testimonial.should be_valid    
  end
  
  it "is valid without text" do
    @testimonial.text = nil
    @testimonial.should be_valid
  end
  
  it "is not valid without valid grade" do
    @testimonial.grade = nil
    @testimonial.should_not be_valid    
    @testimonial.grade = -1
    @testimonial.should_not be_valid
    @testimonial.grade = 2
    @testimonial.should_not be_valid    
    @testimonial.grade = 1
    @testimonial.should be_valid
  end      
  
end
