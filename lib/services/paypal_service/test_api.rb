require_relative 'test_api_builder'

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
      if @should_fail
        ErrorResponse.new(false, [Error.new(@error_code, "error msg")])
      else
        SuccessResponse.new(true, val)
      end
    end

    def do_nothing(val)
      val
    end
  end
end
