require 'spec_helper'

describe DropdownValue do
  describe "validations" do
    it "should have 1 selected options" do
      # Hard-coded 1 for dropdown
      @value = DropdownValue.new
      @value.should_not be_valid

      @value1 = DropdownValue.new
      @value1.custom_field_option_selections << CustomFieldOptionSelection.new
      @value1.should be_valid

      @value2 = DropdownValue.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.should_not be_valid
    end
  end
end
