module PaypalService
  class Logger

    def info(msg, type = :other)
      Rails.logger.info(to_json_log_entry(type, msg, nil))
    end

    def warn(msg, type = :other)
      Rails.logger.warn(to_json_log_entry(type, msg, nil))
    end

    def error(msg, type = :other)
      Rails.logger.error(to_json_log_entry(type, msg, nil))
    end

    def log_request_input(request, input)
      Rails.logger.info(to_json_log_entry(:request,
                                          nil,
                                          {method: request[:method]}.merge(Maybe(input).or_else({}))))
    end

    def log_response(resp)
      Rails.logger.info(to_json_log_entry(:response,
                                          nil,
                                          resp)) unless resp.nil?
    end

    def to_json_log_entry(type, free, structured)
      {
        tag: :paypal,
        type: type,
        free: free,
        structured: structured
      }.to_json
    end
  end
end

