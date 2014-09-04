# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float
#  max            :float
#  allow_decimals :boolean          default(FALSE)
#
# Indexes
#
#  index_custom_fields_on_community_id  (community_id)
#

require 'spec_helper'

describe CustomField do
  # These tests are testing FactoryGirl, not production code, thus,
  # these tests can be safely removed if needed
  describe "factory" do
    describe "build" do
      it "valid entity" do
        @custom_field = FactoryGirl.build(:custom_dropdown_field)
        @custom_field.should be_valid
      end

      it "sets defaults" do
        @custom_field = FactoryGirl.build(:custom_dropdown_field)
        @custom_field.names.length.should == 1
        @custom_field.names.first.value.should == "Test field"
      end

      describe "allows override defaults" do
        it "with empty value" do
          @custom_field = FactoryGirl.build(:custom_dropdown_field, names: [])
          @custom_field.should be_valid
          # This is not possible. If you pass empty array, then factory girl uses defaults
          # @custom_field.names.length.should == 0
        end

        it "with custom value" do
          @custom_field = FactoryGirl.build(:custom_dropdown_field, names: [FactoryGirl.build(:custom_field_name, value: "FactoryGirlTest")])
          @custom_field.should be_valid
          @custom_field.names.length.should == 1
          @custom_field.names.first.value.should == "FactoryGirlTest"
        end
      end
    end

    describe "create" do
      it "valid entity" do
        @custom_field = FactoryGirl.create(:custom_dropdown_field)
        @custom_field.should be_valid
      end

      it "doesn't override" do
        @custom_field = FactoryGirl.create(:custom_dropdown_field)
        @custom_field.should be_valid
      end

      describe "allows override defaults" do
        it "with empty value" do
          @custom_field = FactoryGirl.create(:custom_dropdown_field, names: [])
          @custom_field.should be_valid
          # This is not possible. If you pass empty array, then factory girl uses defaults
          # @custom_field.names.length.should == 0
        end

        it "with custom value" do
          @custom_field = FactoryGirl.create(:custom_dropdown_field, names: [FactoryGirl.build(:custom_field_name, value: "FactoryGirlTest")])
          @custom_field.should be_valid
          @custom_field.names.length.should == 1
          @custom_field.names.first.value.should == "FactoryGirlTest"
        end
      end
    end
  end

  describe "validations" do
    before(:each) do
      # Create valid CustomField entity
      @custom_field = FactoryGirl.create(:custom_dropdown_field)
      @custom_field.should be_valid
    end

    it "should have min 1 name" do
      @custom_field.names = []
      @custom_field.should_not be_valid
    end

    it "should have min 1 category" do
      @custom_field.category_custom_fields = []
      @custom_field.should_not be_valid
    end
  end
end
