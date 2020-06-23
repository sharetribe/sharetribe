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

class DropdownFieldValue < OptionFieldValue
  validate :validate_selections

  private

  def validate_selections
    if question&.for_person?
      return true unless question.required?
    end
    unless custom_field_option_selections.size == 1
      errors.add(:custom_field_option_selections, :'wrong_length.one', {count: 1})
    end
  end
end
