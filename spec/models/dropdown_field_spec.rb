require 'spec_helper'

describe Dropdown do
  describe "validations" do
    before(:each) do
      # Create valid Dropdown entity
      @dropdown = Dropdown.new
      @dropdown.category_custom_fields << FactoryGirl.build(:category_custom_field, :custom_field => @dropdown_field)
      @dropdown.names << CustomFieldName.new(:locale => "en", :value => "Field name")
      option1 = CustomFieldOption.new()
      option1_title = CustomFieldOptionTitle.new(:locale => "en", :value => "Field option1")
      option1.titles << option1_title
      option2 = CustomFieldOption.new()
      option2_title = CustomFieldOptionTitle.new(:locale => "en", :value => "Field option2")
      option2.titles << option2_title
      @dropdown.options << [option1, option2]
      @dropdown.should be_valid
    end

    it "should have min 2 options" do
      @dropdown.options = []
      @dropdown.should_not be_valid
    end
  end
end
