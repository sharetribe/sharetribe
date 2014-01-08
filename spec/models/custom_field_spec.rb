require 'spec_helper'

describe CustomField do
  describe "validations" do
    before(:each) do
      # Create valid CustomField entity
      @custom_field = CustomField.new
      @custom_field.categories << FactoryGirl.build(:category)
      @custom_field.names << CustomFieldName.new(:locale => "en", :value => "Field name")
      @custom_field.should be_valid
    end

    it "should have min 1 name" do
      @custom_field.names = []
      @custom_field.should_not be_valid
    end

    it "should have min 1 category" do
      @custom_field.names = []
      @custom_field.should_not be_valid
    end
  end
end
