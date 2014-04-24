require 'spec_helper'

describe DateFieldValue do
  describe "validations" do
    it "should have date value" do
      @value = DateFieldValue.new
      @value.should_not be_valid
    end

    it "should have date format value" do
      @value2 = DateFieldValue.new
      @value2.date_value = "Test"
      @value2.should_not be_valid
      @value2.errors.should have_key(:date_value)

      @value3 = DateFieldValue.new
      @value3.date_value = Time.now
      @value3.should be_valid
      @value3.errors.should_not have_key(:date_value)
    end
  end
end
