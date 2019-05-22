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

describe TextFieldValue, type: :model do
  let(:field)   { FactoryGirl.create :custom_text_field, required: false }
  let(:required_field)   { FactoryGirl.create :custom_text_field, required: true }

  describe "validations" do
    it "should treat text value as optional if field is not required" do
      value = TextFieldValue.new(question: field)
      expect(value).to be_valid
    end

    it "should have text value" do
      value = TextFieldValue.new(question: required_field)
      expect(value).not_to be_valid
      value.text_value = "Test"
      expect(value).to be_valid
    end
  end
end
