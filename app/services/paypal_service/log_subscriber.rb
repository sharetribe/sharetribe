module PaypalService
  class LogSubscriber < ActiveSupport::LogSubscriber
    def exec_action(event)
      return unless logger.debug? #TODO: change to something more reasonable when ready

      response = event.payload[:response]
      success = response[:success] ? "success" : "failure"
      msg = response[:success] ? response[:msg] : response[:error_msg]
      paypal_action = "[#{event.payload[:action]}] [#{event.end}] [#{event.duration} ms] [#{success}] #{msg}"

      debug "[Paypal] #{paypal_action}"
    end
  end
end
PaypalService::LogSubscriber.attach_to :paypal
