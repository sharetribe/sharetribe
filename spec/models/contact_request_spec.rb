require 'spec_helper'

describe ContactRequest do

  before(:each) do
    @contact_request = FactoryGirl.build(:contact_request)
  end

  it "is valid with valid attributes" do
    @contact_request.should be_valid
  end

end
