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
   attributes :id, :custom_field_id, :listing_id, :text_value, :numeric_value, :date_value, :type, :delta, :person_id, :selections
   

   def selections
      if object.type == "CheckboxFieldValue" 
        #return CustomFieldOptionSelection.find_all_by(listing_id: object.listing_id, custom_field_value_id: object.id).custom_field_option_id
        return CustomFieldOptionSelection.where(listing_id: object.listing_id).where(custom_field_value_id: object.id).pluck(:custom_field_option_id)
      else
         return
      end
   end

   #has_many :custom_field_option_selections
   
   
   # belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
end