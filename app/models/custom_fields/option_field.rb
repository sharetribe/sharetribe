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

class OptionField < CustomField
  has_many :options, :class_name => "CustomFieldOption", :dependent => :destroy, :foreign_key => 'custom_field_id'

  def option_attributes=(attributes)
    new_option_ids = []
    # FIXME: Without this options.each loop Rails seems to sometimes confuse which option
    # has which titles, which causes weird bugs. An example: if user first adds 2 new options
    # and then removes the second one of the existing options, the titles of the last one of the new
    # options will be deleted.
    options.each { |o| o }
    attributes.each do |option_id, option_values|
      if option = CustomFieldOption.where(:id => option_id).first
        option.update_attributes(option_values)
      else
        option =  new_record? ? options.build(option_values) : options.create(option_values)
      end
      new_option_ids << option.id
    end
    options.each { |option| option.destroy unless new_option_ids.include?(option.id) }
  end

end
