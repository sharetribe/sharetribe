require 'spec_helper'

describe CustomFieldValue do
  describe "validations" do
    it "should have 1 selected options" do
      # Hard-coded 1 for dropdown
      @value = CustomFieldValue.new
      @value.should_not be_valid

      @value1 = CustomFieldValue.new
      @value1.custom_field_option_selections << CustomFieldOptionSelection.new
      @value1.should be_valid

      @value2 = CustomFieldValue.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.should_not be_valid

      @value3 = CustomFieldValue.new
      @value3.text_value = "Test" 
      @value3.should be_valid
    end
  end
end