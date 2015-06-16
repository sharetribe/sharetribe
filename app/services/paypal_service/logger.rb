module PaypalService
  class Logger

    def info(msg)
      Rails.logger.info ({ paypal: msg }.to_json)
    end

    def warn(msg)
      Rails.logger.warn ({ paypal: { type: :warning, message: msg } }.to_json)
    end

    def error(msg)
      Rails.logger.error ({ paypal: { type: :error, message: msg } }.to_json)
    end

    def log_request_input(request, input)
      info({type: :request, method: request[:method]}.merge(Maybe(input).or_else({})))
    end

    def log_response(resp)
      info({type: :response, content: response_to_log_str(resp)}) unless resp.nil?
    end

    def response_to_log_str(resp)
      if (resp.respond_to? :to_json)
        resp
      elsif (res.respond_to? :to_s)
        resp.to_s
      else
        ""
      end
    end
  end
end
