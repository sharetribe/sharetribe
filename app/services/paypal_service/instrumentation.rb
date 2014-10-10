module PaypalService
  module Instrumentation
    def exec_action(*args)
      raw_payload = {
        api: self.class.name
      }

      ActiveSupport::Notifications.instrument("exec_action.paypal", raw_payload) do |payload|
        result = super
        payload[:response] = result
        result
      end
    end
  end
end
