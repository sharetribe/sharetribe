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
      request_id = SecureRandom.uuid
      Rails.logger.info(to_json_log_entry(:request,
                                          nil,
                                          {method: request[:method]}.merge(Maybe(input).or_else({})),
                                          request_id))

      request_id
    end

    def log_response(resp, request_id)
      Rails.logger.info(to_json_log_entry(:response,
                                          nil,
                                          resp,
                                          request_id)) unless resp.nil?
    end

    def to_json_log_entry(type, free, structured, request_id = nil)
      {
        tag: :paypal,
        type: type,
        free: free,
        structured: structured,
        request_id: request_id,
      }.to_json
    end
  end
end

