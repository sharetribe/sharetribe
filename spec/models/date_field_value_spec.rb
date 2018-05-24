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

describe DateFieldValue, type: :model do
  describe "validations" do
    it "should have date value" do
      @value = DateFieldValue.new
      expect(@value).not_to be_valid
    end

    it "should have date format value" do
      @value2 = DateFieldValue.new
      @value2.date_value = "Test"
      expect(@value2).not_to be_valid
      expect(@value2.errors).to have_key(:date_value)

      @value3 = DateFieldValue.new
      @value3.date_value = Time.now
      expect(@value3).to be_valid
      expect(@value3.errors).not_to have_key(:date_value)
    end
  end
end
