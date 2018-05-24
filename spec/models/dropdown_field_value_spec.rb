# == Schema Information
#
# Table name: custom_field_values
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  listing_id      :integer
#  text_value      :text(65535)
#  numeric_value   :float(24)
#  date_value      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  delta           :boolean          default(TRUE), not null
#  person_id       :string(255)
#
# Indexes
#
#  index_custom_field_values_on_listing_id  (listing_id)
#  index_custom_field_values_on_person_id   (person_id)
#  index_custom_field_values_on_type        (type)
#

require 'spec_helper'

describe DropdownFieldValue, type: :model do
  describe "validations" do
    it "should have 1 selected options" do
      # Hard-coded 1 for dropdown
      @value = DropdownFieldValue.new
      expect(@value).not_to be_valid

      @value1 = DropdownFieldValue.new
      @value1.custom_field_option_selections << CustomFieldOptionSelection.new
      expect(@value1).to be_valid

      @value2 = DropdownFieldValue.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      @value2.custom_field_option_selections << CustomFieldOptionSelection.new
      expect(@value2).not_to be_valid
    end
  end
end
