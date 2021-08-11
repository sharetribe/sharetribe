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
class CustomFieldValueSerializer < ActiveModel::Serializer
   attributes :id, :custom_field_id, :listing_id, :text_value, :numeric_value, :date_value, :type, :delta, :person_id
   
   # def init 
   #    if :type == CheckboxField do
   #       has_many :custom_field_option_selections, class_name: "CustomFieldOptionSelection"
   #    end
   # end
   has_many :custom_field_option_selections, class_name: "CustomFieldOptionSelection"
   # belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
end