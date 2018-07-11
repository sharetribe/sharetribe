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

describe Numeric, type: :model do
  describe "validations" do
    let(:numeric) { FactoryGirl.build(:custom_numeric_field) }

    it "should have min and max values" do
      numeric.min = nil
      numeric.max = nil
      expect(numeric).not_to be_valid

      numeric.min = 0
      expect(numeric).not_to be_valid

      numeric.max = 9999
      expect(numeric).to be_valid

      # Must be number
      numeric.min = "not a number"
      expect(numeric).not_to be_valid

      # Must be greater (equal is not enough)
      numeric.min = numeric.max
      expect(numeric).not_to be_valid

      numeric.max = numeric.min + 1
      expect(numeric).to be_valid
    end
  end
end
