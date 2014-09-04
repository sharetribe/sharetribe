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

describe TextFieldValue do
  describe "validations" do
    it "should have text value" do
      @value = TextFieldValue.new
      @value.should_not be_valid

      @value3 = TextFieldValue.new
      @value3.text_value = "Test"
      @value3.should be_valid
    end
  end
end
