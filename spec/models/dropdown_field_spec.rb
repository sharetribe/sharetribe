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

describe DropdownField, type: :model do
  describe "validations" do
    before(:each) do
      # Create valid Dropdown entity
      @dropdown = FactoryGirl.create(:custom_dropdown_field)
      expect(@dropdown).to be_valid
    end

    it "should have min 2 options" do
      @dropdown.options = []
      expect(@dropdown).not_to be_valid
    end
  end
end
