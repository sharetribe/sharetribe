module BTLog
  class << self
    def info(msg)
      # Currently, we're showing only warn and error levels. However, we want to show Braintree infos
      Rails.logger.warn "[Braintree] #{msg}"
    end

    def warn(msg)
      Rails.logger.warn "[Braintree] #{msg}"
    end

    def error(msg)
      Rails.logger.error "[Braintree] #{msg}"
    end
  end
end
