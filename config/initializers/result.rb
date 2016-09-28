# This file implements an "adapter" between the old and new Result implementation
#
# The "adapter" is basically just a big bunch of monkey-patches that add the
# deprecated methods to the new implementation.
#
# In addition to that, there are some methods that should be moved to the new
# implementation.
#
# In order to see the full stack trace for deprecation warnings, turn on debug mode:
#
# `ActiveSupport::Deprecation.debug = true`
#

module Result
  class Result
    def maybe
      ActiveSupport::Deprecation.warn("[Result] Using deprecated method `maybe`. Use `and_then` instead.")

      if success?
        Maybe(data)
      else
        None()
      end
    end

    def success
      ActiveSupport::Deprecation.warn("[Result] Using deprecated method `success`. Use `success?` (with question mark) instead.")

      success?
    end

    def on_error(&block)
      ActiveSupport::Deprecation.warn("[Result] Using deprecated method `on_error { |error_msg, data| ... }`. Use `on_failure { |error, error_msg, data| ... }` instead.")

      on_failure { |error, error_msg, data|
        block.call(error_msg, data)
      }
    end

    def members
      ActiveSupport::Deprecation.warn("[Result] Using deprecated method `members`. Use `.to_h.keys` instead")

      to_h.keys
    end

    #
    # The following methods should be added to Result implementation:
    #

    def to_h
      {
        success: success?,
        data: data
      }
    end

    def [](key)
      to_h[key]
    end
  end

  class Success

    #
    # The following methods should be added to Result implementation:
    #

    def ==(other)
      other.is_a?(Success) && other.data == data
    end

    def rescue(&block)
      self
    end
  end

  class Failure

    #
    # The following methods should be added to Result implementation:
    #

    def ==(other)
      other.is_a?(Failure) && other.error == error && other.error_msg = error_msg && other.data == data
    end

    def rescue(&block)
      result = block.call(error, error_msg, data)
      result.tap do |res|
        raise ArgumentError.new("Block must return Result") unless (res.is_a?(Success) || res.is_a?(Failure))
      end
    end

    def to_h
      super.merge(
        error: error,
        error_msg: error_msg)
    end
  end

  class Error < Failure
    def initialize(error_msg, data = nil)
      ActiveSupport::Deprecation.warn("[Result] Using deprecated error class Error. Use Failure instead")

      if (error_msg.is_a? StandardError)
        ex = error_msg
        super(nil, ex.message, ex)
      else
        super(nil, error_msg, data)
      end
    end
  end

  module_function

  # Runs the given operations (lambdas) sequentially.
  # The result data from the first operation is passed to the second operation, and so on
  # If you are not interested in the previous operation result, you can ignore them, but you have
  # to let the lambda allow n-number of arguments.
  #
  # Usage:
  #
  # fetch_user = ->() { UserService.fetch(user_id) }
  # fetch_user_email = ->(user) { EmailService.fetch(user[:email_id]) }
  # send_authentication_token = ->(user, email) { AuthenticationService.send_token(user[:name], email[:address]) }
  #
  # authentication_send_result = Result.all(fetch_user, fetch_user_email, send_authentication_token)
  #
  def all(*operations)
    ActiveSupport::Deprecation.warn("[Result] Using deprecated helper method `all`. There's no implementation for this in the new Result. You need to either add it to the Result object, or add a ResultUtils.all utility to the application code.")

    operations.inject(Success.new([])) { |res, op|
      if res.success
        res_data = res.data
        op_res = op.call(*res_data)

        raise ArgumentError.new("Lambda must return Result") unless (op_res.is_a?(Success) || op_res.is_a?(Failure))

        if op_res.success
          Success.new(res_data.concat([op_res.data]))
        else
          op_res
        end
      else
        res
      end
    }
  end
end
