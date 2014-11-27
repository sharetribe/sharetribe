# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float
#  max            :float
#  allow_decimals :boolean          default(FALSE)
#
# Indexes
#
#  index_custom_fields_on_community_id  (community_id)
#

class DropdownField < OptionField
  validates_length_of :options, :minimum => 2

  def with_type(&block)
    block.call(:dropdown)
  end

  def can_filter?
    true
  end
end
