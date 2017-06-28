class Logger
  cattr_accessor :silencer
  self.silencer = true

  def silence(temporary_level = Logger::ERROR)
    if silencer
      begin
        old_local_level = level
        self.level = temporary_level

        yield self
      ensure
        self.level = old_local_level
      end
    else
      yield self
    end
  end

end
