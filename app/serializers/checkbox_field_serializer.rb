# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#  entity_type    :integer          default("for_listing")
#  public         :boolean          default(FALSE)
#  assignment     :integer          default("unassigned")
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#
class CheckboxFieldSerializer < ActiveModel::Serializer
   attributes :id, :type, :search_filter, :required
   #:sort_priority, :search_filter, :required, :min, :max, :allow_decimals, :entity_type, :public, :assignment
   has_many :names, class_name: "CustomFieldName"
   has_many :category_custom_fields
   # has_many :categories
   #has_many :answers, class_name: "CustomFieldValue"
   #has_many :custom_field_option_selection, class_name: "CustomFieldOptionSelection"
   has_many :options, class_name: "CustomFieldOption"
end