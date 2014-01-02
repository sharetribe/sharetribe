class CustomField < ActiveRecord::Base
  attr_accessible :type, :name_attributes
  
  has_many :custom_field_names
  
  def name_attributes=(attributes)
    attributes.each { |a| custom_field_names.build(a) }
  end
  
end
