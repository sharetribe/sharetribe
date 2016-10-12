module PaypalService
  class TestApiBuilder
    def initialize
      # We maintain a queue of next response type, elems are :ok or "error_code".
      # Empty queue implicitly means :ok
      @next_responses = []
    end

    def will_respond_with(response_types)
      @next_responses = response_types
    end

    def will_fail(times, error_code)
      will_respond_with(Array.new(times).map { error_code })
    end

    def call(req)
      res_type = @next_responses.shift
      if (res_type.is_a? String)
        TestApi.new(req[:receiver_username], true, res_type)
      else
        TestApi.new(req[:receiver_username])
      end
    end
  end
end
