require 'spec_helper'

describe NumericFieldValue do
  describe "validations" do
    it "should have text value" do
      @value = NumericFieldValue.new
      @value.should_not be_valid

      # Has to be number
      @value.numeric_value = 0
      @value.should be_valid
      @value.numeric_value = "jee"
      @value.should_not be_valid
    end
  end
end