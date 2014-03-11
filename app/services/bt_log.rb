module BTLog
  class << self
    def info(msg)
      Rails.logger.info "[Braintree] #{msg}"
    end

    def warn(msg)
      Rails.logger.warn "[Braintree] #{msg}"
    end

    def error(msg)
      Rails.logger.error "[Braintree] #{msg}"
    end
  end
end