module TransitUtils

  class UUIDWriteHandler
    def tag(_)
      "u"
    end

    def rep(u)
      tu = Transit::UUID.new(u.to_s)
      [tu.most_significant_bits, tu.least_significant_bits]
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

  # Takes `content` (String) and `encoding` and decodes the Transit
  # message
  def decode(content, encoding)
    Transit::Reader.new(
      encoding,
      StringIO.new(content),
      handlers: {
        "u" => UUIDReadHandler.new
      }).read
  end

end
