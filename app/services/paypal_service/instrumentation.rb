module PaypalService
  module Instrumentation

    module_function

    def log_action(action = "", &block)
      raw_payload = {
        action: action
      }

      ActiveSupport::Notifications.instrument("exec_action.paypal", raw_payload) do |payload|
        result = yield
        payload[:response] = result
        result
      end
    end
  end
end
