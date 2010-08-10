require 'spec_helper'

describe Participation do
  
  before(:each) do
    @participation = Factory.build(:participation)
  end
  
  it "is valid with valid attributes" do
    @participation.should be_valid
  end
  
end
