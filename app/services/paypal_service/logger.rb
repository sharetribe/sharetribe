module PaypalService
  class Logger

    def info(type, msg)
      Rails.logger.info(to_json_log_entry({type: type, content: msg }))
    end

    def warn(msg)
      Rails.logger.warn(to_json_log_entry({type: :warning, message: msg }))
    end

    def error(msg)
      Rails.logger.error(to_json_log_entry({type: :error, message: msg }))
    end

    def log_request_input(request, input)
      info(:request, {method: request[:method]}.merge(Maybe(input).or_else({})))
    end

    def log_response(resp)
      info(:response, resp ) unless resp.nil?
    end

    def to_json_log_entry(type:, message:, content:)
      {
        paypal:
          {
            type: type,
            message: message,
            content: content
          }
      }.to_json
    end

  end
end
