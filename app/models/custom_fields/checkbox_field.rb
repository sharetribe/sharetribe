class CheckboxField < OptionField
  validates_length_of :options, :minimum => 1

  def with_type(&block)
    block.call(:checkbox)
  end
end
