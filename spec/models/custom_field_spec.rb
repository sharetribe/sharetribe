# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#  entity_type    :integer          default("for_listing")
#  public         :boolean          default(FALSE)
#  assignment     :integer          default("unassigned")
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#

require 'spec_helper'

describe CustomField, type: :model do
  # These tests are testing FactoryGirl, not production code, thus,
  # these tests can be safely removed if needed
  describe "factory" do
    describe "build" do
      it "valid entity" do
        @custom_field = FactoryGirl.build(:custom_dropdown_field)
        expect(@custom_field).to be_valid
      end

      it "sets defaults" do
        @custom_field = FactoryGirl.build(:custom_dropdown_field)
        expect(@custom_field.names.length).to eq(1)
        expect(@custom_field.names.first.value).to eq("Test field")
      end

      describe "allows override defaults" do
        it "with empty value" do
          @custom_field = FactoryGirl.build(:custom_dropdown_field, names: [])
          expect(@custom_field).to be_valid
          # This is not possible. If you pass empty array, then factory girl uses defaults
          # @custom_field.names.length.should == 0
        end

        it "with custom value" do
          @custom_field = FactoryGirl.build(:custom_dropdown_field, names: [FactoryGirl.build(:custom_field_name, value: "FactoryGirlTest")])
          expect(@custom_field).to be_valid
          expect(@custom_field.names.length).to eq(1)
          expect(@custom_field.names.first.value).to eq("FactoryGirlTest")
        end
      end
    end

    describe "create" do
      it "valid entity" do
        @custom_field = FactoryGirl.create(:custom_dropdown_field)
        expect(@custom_field).to be_valid
      end

      it "doesn't override" do
        @custom_field = FactoryGirl.create(:custom_dropdown_field)
        expect(@custom_field).to be_valid
      end

      describe "allows override defaults" do
        it "with empty value" do
          @custom_field = FactoryGirl.create(:custom_dropdown_field, names: [])
          expect(@custom_field).to be_valid
          # This is not possible. If you pass empty array, then factory girl uses defaults
          # @custom_field.names.length.should == 0
        end

        it "with custom value" do
          @custom_field = FactoryGirl.create(:custom_dropdown_field, names: [FactoryGirl.build(:custom_field_name, value: "FactoryGirlTest")])
          expect(@custom_field).to be_valid
          expect(@custom_field.names.length).to eq(1)
          expect(@custom_field.names.first.value).to eq("FactoryGirlTest")
        end
      end
    end
  end

  describe "validations" do
    before(:each) do
      # Create valid CustomField entity
      @custom_field = FactoryGirl.create(:custom_dropdown_field)
      expect(@custom_field).to be_valid
    end

    it "should have min 1 name" do
      @custom_field.names = []
      expect(@custom_field).not_to be_valid
    end

    it "should have min 1 category" do
      @custom_field.category_custom_fields = []
      expect(@custom_field).not_to be_valid
    end
  end
end
