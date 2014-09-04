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

describe DateFieldValue do
  describe "validations" do
    it "should have date value" do
      @value = DateFieldValue.new
      @value.should_not be_valid
    end

    it "should have date format value" do
      @value2 = DateFieldValue.new
      @value2.date_value = "Test"
      @value2.should_not be_valid
      @value2.errors.should have_key(:date_value)

      @value3 = DateFieldValue.new
      @value3.date_value = Time.now
      @value3.should be_valid
      @value3.errors.should_not have_key(:date_value)
    end
  end
end
