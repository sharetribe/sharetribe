require 'spec_helper'

describe Numeric do
  describe "validations" do
    let(:numeric) { FactoryGirl.build(:custom_numeric_field) }

    it "should have min and max values" do
      numeric.should_not be_valid

      numeric.min = 0
      numeric.should_not be_valid

      numeric.max = 9999
      numeric.should be_valid
    end
  end
end
