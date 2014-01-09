require 'spec_helper'

describe CustomFieldOption do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldOptionTitle.new
      @name.should_not be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en")
      @name2.should_not be_valid

      @name2 = CustomFieldOptionTitle.new(:locale => "en", :value => "Field name")
      @name2.should be_valid
    end
  end
end
