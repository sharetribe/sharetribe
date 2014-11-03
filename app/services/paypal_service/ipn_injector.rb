module PaypalService::IPNInjector

  def ipn_service
    @ipn ||= build_ipn_handler
  end

  module_function

  def build_ipn_handler
    events = Events.new({
        payment_voided: -> (flow, ipn_entity) { TransactionService::PaypalEvents.payment_updated(flow, ipn_entity) }
      })

    PaypalService::IPN.new(events)
  end
end
