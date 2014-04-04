require 'spec_helper'

describe Participation do

  before(:each) do
    @participation = FactoryGirl.build(:participation)
  end

  it "is valid with valid attributes" do
    @participation.should be_valid
  end

end
