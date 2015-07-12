module PaypalService

  class TestApi
    attr_reader :config
    SuccessResponse = Struct.new(:success?, :value)
    ErrorResponse = Struct.new(:success?, :errors)
    Error = Struct.new(:error_code, :long_message)

    Config = Struct.new(:subject)

    def initialize(subject, should_fail = false, error_code = nil)
      @config = Config.new(subject || "test_username")
      @should_fail = should_fail
      @error_code = error_code
    end

    def wrap(val)
      unless @should_fail
        SuccessResponse.new(true, val)
      else
        ErrorResponse.new(false, [Error.new(@error_code, "error msg")])
      end
    end

    def do_nothing(val)
      val
    end
  end

  class TestApiBuilder
    def initialize()
      # We maintain a queue of next response type, elems are :ok or "error_code".
      # Empty queue implicitly means :ok
      @next_responses = []
    end

    def will_respond_with(response_types)
      @next_responses = response_types
    end

    def will_fail(times, error_code)
      will_respond_with(times.times.map { error_code })
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
