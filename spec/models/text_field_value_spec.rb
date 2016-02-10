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
#
# Indexes
#
#  index_custom_field_values_on_listing_id  (listing_id)
#  index_custom_field_values_on_type        (type)
#

require 'spec_helper'

describe TextFieldValue, type: :model do
  describe "validations" do
    it "should have text value" do
      @value = TextFieldValue.new
      expect(@value).not_to be_valid

      @value3 = TextFieldValue.new
      @value3.text_value = "Test"
      expect(@value3).to be_valid
    end
  end
end
