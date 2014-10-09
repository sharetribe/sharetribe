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
      info("paypal response: #{resp.to_json}") unless resp.nil?
    end
  end
end
