# == Schema Information
#
# Table name: custom_field_values
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  listing_id      :integer
#  text_value      :text
#  numeric_value   :float
#  date_value      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  delta           :boolean          default(TRUE), not null
#
# Indexes
#
#  index_custom_field_values_on_listing_id  (listing_id)
#

require 'spec_helper'

describe DropdownFieldValue do
  describe "validations" do
    it "should have 1 selected options" do
      # Hard-coded 1 for dropdown
      @value = DropdownFieldValue.new
      @value.should_not be_valid

      @value1 = DropdownFieldValue.new
      @value1.custom_field_option_selections << CustomFieldOptionSelection.new
      @value1.should be_valid

      @value2 = DropdownFieldValue.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.should_not be_valid
    end
  end
end
