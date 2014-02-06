module LoggingHelper
  def print_dot
    print "."
    STDOUT.flush
  end

  # Prints without newline and flushes STDOUT
  def print_stat(string)
    print string
    STDOUT.flush
  end
end