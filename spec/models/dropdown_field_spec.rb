require 'spec_helper'

describe DropdownField do
  describe "validations" do
    before(:each) do
      # Create valid Dropdown entity
      @dropdown = FactoryGirl.create(:custom_dropdown_field)
      @dropdown.should be_valid
    end

    it "should have min 2 options" do
      @dropdown.options = []
      @dropdown.should_not be_valid
    end
  end
end
