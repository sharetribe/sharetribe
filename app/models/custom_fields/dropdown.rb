class Dropdown < OptionField
  validates_length_of :options, :minimum => 2

  def with_type(&block)
    block.call(:dropdown)
  end
end
