require 'spec_helper'

describe CustomFieldName do
  describe "validations" do
    it "should have locale and value" do
      @name = CustomFieldName.new
      @name.should_not be_valid

      @name2 = CustomFieldName.new(:locale => "en")
      @name2.should_not be_valid

      @name2 = CustomFieldName.new(:locale => "en", :value => "Field name")
      @name2.should be_valid
    end
  end
end
