module TransitUtils
  module_function

  def encode(content, encoding)
    io = StringIO.new('', 'w+')
    writer = Transit::Writer.new(encoding, io)
    writer.write(content)
    io.string
  end

  def decode(content, encoding)
    Transit::Reader.new(encoding, StringIO.new(content)).read
  end
end
