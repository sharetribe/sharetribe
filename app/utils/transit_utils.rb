module TransitUtils

  class UUIDWriteHandler
    def tag(_)
      "u"
    end

    def rep(u)
      Transit::UUID.new(u.to_s)
    end

    def string_rep(u)
      u.to_s
    end
  end

  class UUIDReadHandler
    def from_rep(u)
      UUIDTools::UUID.parse(Transit::UUID.new(u).to_s)
    end
  end

  module_function

  def encode(content, encoding)
    io = StringIO.new('', 'w+')

    writer = Transit::Writer.new(
      encoding,
      io,
      handlers: {
        UUIDTools::UUID => UUIDWriteHandler.new
      })
    writer.write(content)
    io.string
  end

  def decode(content, encoding)
    Transit::Reader.new(
      encoding,
      StringIO.new(content),
      handlers: {
        "u" => UUIDReadHandler.new
      }).read
  end
end
