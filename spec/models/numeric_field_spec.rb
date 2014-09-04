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

describe Numeric do
  describe "validations" do
    let(:numeric) { FactoryGirl.build(:custom_numeric_field) }

    it "should have min and max values" do
      numeric.min = nil
      numeric.max = nil
      numeric.should_not be_valid

      numeric.min = 0
      numeric.should_not be_valid

      numeric.max = 9999
      numeric.should be_valid

      # Must be number
      numeric.min = "not a number"
      numeric.should_not be_valid

      # Must be greater (equal is not enough)
      numeric.min = numeric.max
      numeric.should_not be_valid

      numeric.max = numeric.min + 1
      numeric.should be_valid
    end
  end
end
