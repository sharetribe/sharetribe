require 'spec_helper'

describe DropdownField do
  describe "validations" do
    before(:each) do
      # Create valid DropdownField entity
      @dropdown_field = DropdownField.new
      @dropdown_field.categories << FactoryGirl.build(:category)
      @dropdown_field.names << CustomFieldName.new(:locale => "en", :value => "Field name")
      option1 = CustomFieldOption.new()
      option1_title = CustomFieldOptionTitle.new(:locale => "en", :value => "Field option1")
      option1.titles << option1_title
      option2 = CustomFieldOption.new()
      option2_title = CustomFieldOptionTitle.new(:locale => "en", :value => "Field option2")
      option2.titles << option2_title
      @dropdown_field.options << [option1, option2]
      @dropdown_field.should be_valid
    end

    it "should have min 2 options" do
      @dropdown_field.options = []
      @dropdown_field.should_not be_valid
    end
  end
end
