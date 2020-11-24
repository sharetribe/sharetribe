module PaypalService
  class TestLogger
    def method_missing(m, *args, &block) # rubocop:disable Style/MissingRespondToMissing
      # Do nothing
    end
  end
end
