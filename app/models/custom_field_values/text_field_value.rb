class TextFieldValue < CustomFieldValue

  attr_accessible :text_value

  validates_presence_of :text_value

end
