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
    #
    # ## Map an Error to a Success
    #
    # ```ruby
    # result = client.get(:create_thing).rescue { |error_msg, data|
    #   case error_msg
    #   when :thing_already_exists
    #     Result::Success.new("Thing already created")
    #   else
    #     Result::Error.new(error_msg, data)
    #   end
    # }
    def and_then(&block)
      result = block.call(data)
      result.tap do |res|
        raise ArgumentError.new("Block must return Result") unless (res.is_a?(Result::Success) || res.is_a?(Result::Error))
      end
    end

    # Error a -> Result b
    # No-op
    def rescue(&block)
      self
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
    :data,
    :exception
  ) do

    def initialize(error_msg, data = nil)
      self.success = false
      self.exception = [error_msg, caller.join(", ")]
      if (error_msg.is_a? StandardError)
        ex = error_msg
        self.error_msg = ex.message
        self.data = ex
      else
        self.error_msg = error_msg
        self.data = data
      end
      rewrite_stripe_errors
    end

    # Error a -> Error a
    # No-op
    def and_then(&block)
      self
    end

    # Error a -> Result b
    def rescue(&block)
      result = block.call(error_msg, data)
      result.tap do |res|
        raise ArgumentError.new("Block must return Result") unless (res.is_a?(Result::Success) || res.is_a?(Result::Error))
      end
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

    def rewrite_stripe_errors
      if error_msg && error_msg =~ /You can only create new accounts if you've registered your platform/
        self.error_msg = I18n.t("payment_settings.wrong_setup")
      end
      if error_msg && error_msg =~ /You cannot use a live bank account number when making transfers or debits in test mode|We couldn't find the bank for this account number/
        self.error_msg = I18n.t("payment_settings.invalid_bank_account_number")
      end
      if error_msg && error_msg =~ /Invalid (\w\w) postal code/
        self.error_msg = I18n.t("payment_settings.invalid_postal_code", :country => CountryI18nHelper.translate_country(Regexp.last_match[1]))
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
