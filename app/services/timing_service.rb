module TimingService
  class << self
    # Give treshold in seconds (optional) and a message which
    # will be logged if the operation given as `block` takes too
    # long.
    #
    # ## Usage:
    # TimingService.log(0.5, "Search takes too long") {
    #   User.search("search terms")
    # }
    #
    def log(threshold=0.5, message=nil, &block)
      beginning_time = Time.now
      result = block.call
      end_time = Time.now

      total_time = end_time - beginning_time

      if (total_time > threshold)
        message ||= "Operation took too long"
        Rails.logger.warn "[PERF] #{message} : #{(end_time - beginning_time)*1000} ms"
      end

      result
    end
  end
end
