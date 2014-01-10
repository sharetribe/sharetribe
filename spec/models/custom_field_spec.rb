require 'spec_helper'

describe CustomField do
  describe "validations" do
    before(:each) do
      # Create valid CustomField entity
      @custom_field = FactoryGirl.create(:custom_field)
      @custom_field.should be_valid
    end

    it "should have min 1 name" do
      @custom_field.names = []
      @custom_field.should_not be_valid
    end

    it "should have min 1 category" do
      @custom_field.category_custom_fields = []
      @custom_field.should_not be_valid
    end
  end
end
