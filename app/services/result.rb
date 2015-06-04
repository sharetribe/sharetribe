module Result

  Success = Struct.new(
    :success, # Boolean
    :data # Additional response data
  ) do

    def initialize(data = nil)
      self.success = true
      self.data = data
    end

    # Success a -> Result b
    # Takes block of type (a -> Result b)
    #
    # Usage examples:
    #
    # ## Chaining queries
    #
    # ```ruby
    # result = accounts_api.get(person_id, community_id).and_then { |account|
    #   payments_api.do_payment(payer: account[:payer_id])
    # }
    #
    # if result[:success]
    #   flash t("successful.payment.to", result[:data][:receiver_id]
    # else
    #   case result[:error_msg]
    #   when :paypal_servers_down
    #     # error message
    #   end
    # end
    #
    # ## Map Success to Error
    #
    # ```ruby
    # result = accounts_api.get(person_id, community_id).and_then { |account|
    #   if account[:payer_id].nil?
    #     Result::Error.new(:not_found)
    #   else
    #     payments_api.do_payment(payer: account[:payer_id])
    #   end
    # }
    def and_then(&block)
      result = block.call(data)
      result.tap do |res|
        raise ArgumentError.new("Block must return Result") unless (res.is_a?(Result::Success) || res.is_a?(Result::Error))
      end
    end

    def on_success(&block)
      block.call(data)
      self
    end

    def on_error(&block)
      # no-op
      self
    end

    # Success a -> Maybe a
    #
    # Usage example:
    #
    # account = accounts_api.get(person_id, community_id).maybe
    # render(locals: { account_email: account[:email].or_else(nil) })
    #
    def maybe()
      Maybe(data)
    end

  end

  Error = Struct.new(
    :success,
    :error_msg,
    :data
  ) do

    def initialize(error_msg, data = nil)
      self.success = false
      self.error_msg = error_msg
      self.data = data
    end

    # Error a -> Error a
    # No-op
    def and_then(&block)
      self
    end

    def on_success(&block)
      # no-op
      self
    end

    def on_error(&block)
      block.call(error_msg, data)
      self
    end

    # Error a -> None
    def maybe()
      Maybe(nil)
    end

  end

  module_function

  def all(*operations)
    operations.inject(Result::Success.new([])) { |res, op|
      if res.success
        res_data = res.data
        op_res = op.call(*res_data)

        raise ArgumentError.new("Lambda must return Result") unless (op_res.is_a?(Result::Success) || op_res.is_a?(Result::Error))

        if op_res.success
          Result::Success.new(res_data.concat([op_res.data]))
        else
          op_res
        end
      else
        res
      end
    }
  end

end
