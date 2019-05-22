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

describe NumericFieldValue, type: :model do
  let(:field)   { FactoryGirl.create :custom_numeric_field, min: 0, max: 50, required: false }
  let(:required_field)   { FactoryGirl.create :custom_numeric_field, min: 0, max: 50, required: true }

  describe "validations" do
    it "should treat numeric value as optional if field is not required" do
      value = NumericFieldValue.new(question: field)
      expect(value).to be_valid
    end

    it "should have numeric value" do
      value = NumericFieldValue.new(question: required_field)
      expect(value).not_to be_valid
      value.numeric_value = 0
      expect(value).to be_valid
      value.numeric_value = "jee"
      expect(value).not_to be_valid
    end
  end

  describe "search", :'no-transaction' => true do
    let!(:short_board)   { FactoryGirl.create :listing, title: "Short board" }
    let!(:medium_board)   { FactoryGirl.create :listing, title: "Medium board" }
    let!(:long_board)    { FactoryGirl.create :listing, title: "Long board" }

    let!(:board_length)  { FactoryGirl.create :custom_numeric_field, min: 0, max: 200 }
    let!(:length_value1) { FactoryGirl.create :custom_numeric_field_value, listing: short_board, question: board_length, numeric_value: 100 }
    let!(:length_value2) { FactoryGirl.create :custom_numeric_field_value, listing: medium_board, question: board_length, numeric_value: 160 }
    let!(:length_value3) { FactoryGirl.create :custom_numeric_field_value, listing: long_board, question: board_length, numeric_value: 200 }

    let!(:board_width)   { FactoryGirl.create :custom_numeric_field, min: 0, max: 50 }
    let!(:width_value1)  { FactoryGirl.create :custom_numeric_field_value, listing: short_board, question: board_width, numeric_value: 30 }
    let!(:width_value3)  { FactoryGirl.create :custom_numeric_field_value, listing: long_board, question: board_width, numeric_value: 40 }

    before(:each) do
      ensure_sphinx_is_running_and_indexed
    end

    def test_search(length, width, expected_count)
      with_many = []
      with_many << if length then {
          custom_field_id: board_length.id,
          numeric_value: length
        }
      end
      with_many << if width then {
          custom_field_id: board_width.id,
          numeric_value: width
        }
      end

      expect(NumericFieldValue.search_many(with_many.compact).count).to eq(expected_count)
    end

    it "searches by numeric field and value pairs" do
      test_search((0..50),  (0..20),  0) # Neither matches
      test_search((0..150), (0..20),  0) # Length matches 1, width matches 0
      test_search((0..150), (0..35),  1) # Length matches 1, width matches 1
      test_search((0..180), nil,      2) # Length matches 2
      test_search((0..220), nil,      3) # Length matches 3
      test_search((0..220), (20..35), 1) # Length matches 3, width matches 1
      test_search((0..220), (20..50), 2) # Length matches 3, width matches 2
    end
  end
end
