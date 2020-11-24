module PaypalService::IPNInjector

  def ipn_service
    @ipn ||= build_ipn_handler
  end

  module_function

  def build_ipn_handler
    events = Events.new({
        payment_updated: -> (flow, payment) { TransactionService::PaypalEvents.payment_updated(flow, payment) }
      })

    PaypalService::IPN.new(events)
  end
end
