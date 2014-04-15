class TextField < CustomField
  def with_type(&block)
    block.call(:text)
  end
end
