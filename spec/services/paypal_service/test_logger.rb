module PaypalService
  class TestLogger
    def method_missing(m, *args, &block)
      # Do nothing
    end
  end
end
