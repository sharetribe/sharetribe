module PaypalService::Jobs
  class RetryAndCleanTokens < Struct.new(:clean_time_limit)

    def perform
      payments_api.retry_and_clean_tokens(clean_time_limit)
    end


    private

    def payments_api
      PaypalService::API::Api.payments
    end
  end
end
