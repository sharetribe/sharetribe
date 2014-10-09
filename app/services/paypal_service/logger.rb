module PaypalService
  class Logger

    def info(msg)
      #TODO: Fix logging totally
      Rails.logger.warn "[Paypal] #{msg}"
    end

    def warn(msg)
      Rails.logger.warn "[Paypal] #{msg}"
    end

    def error(msg)
      Rails.logger.error "[Paypal] #{msg}"
    end

    def log_response(resp)
      info("paypal response: #{response_to_log_str(resp)}") unless resp.nil?
    end

    def response_to_log_str(resp)
      if (resp.respond_to? :to_json)
        resp.to_json
      elsif (res.respond_to? :to_s)
        resp.to_s
      else
        ""
      end
    end
  end
end
