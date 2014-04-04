require 'spec_helper'

describe TextFieldValue do
  describe "validations" do
    it "should have text value" do
      @value = TextFieldValue.new
      @value.should_not be_valid

      @value3 = TextFieldValue.new
      @value3.text_value = "Test"
      @value3.should be_valid
    end
  end
end
