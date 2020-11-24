class FakeFileIO < StringIO
  attr_reader :original_filename
  attr_reader :path

  def initialize(filename, content)
    super(content)
    @original_filename = File.basename(filename)
    @path = File.path(filename)
  end
end
