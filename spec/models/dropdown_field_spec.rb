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

describe DropdownField do
  describe "validations" do
    before(:each) do
      # Create valid Dropdown entity
      @dropdown = FactoryGirl.create(:custom_dropdown_field)
      @dropdown.should be_valid
    end

    it "should have min 2 options" do
      @dropdown.options = []
      @dropdown.should_not be_valid
    end
  end
end
