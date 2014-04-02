class Dropdown < CustomField

  # Idea: In the future, if we have other field types with options (like checkbox or radio button)
  # we could move this to subclasses, etc:
  # Dropdown < OptionField < CustomField
  # Checkbox < OptionField < CustomField
  has_many :options, :class_name => "CustomFieldOption", :dependent => :destroy, :foreign_key => 'custom_field_id'

  validates_length_of :options, :minimum => 2

  def with_type(&block)
    block.call(:dropdown)
  end

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
