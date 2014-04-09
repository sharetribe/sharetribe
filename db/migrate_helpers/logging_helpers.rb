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

  class ProgressReporter
    def initialize(total, every=100)
      @total = total
      @current = 0
      @every = every
      @start = Time.now
    end

    def next
      @current = @current + 1

      if @current % @every == 0
        speed = (Time.now - @start) / @current * @every
        print "(#{@current}/#{@total}, #{speed}s/#{@every} iterations)"
        STDOUT.flush
      end
    end
  end
end