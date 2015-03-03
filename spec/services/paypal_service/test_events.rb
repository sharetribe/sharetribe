module PaypalService
  class TestEvents
    attr_reader :received_events

    ALLOWED_EVENTS = [:request_cancelled, :payment_created, :payment_updated, :order_details]

    def initialize
      clear
    end

    def send(event, *payload)
      raise "Illegal event type: #{event}" unless ALLOWED_EVENTS.include? event

      @received_events[event].push(payload)
    end

    def clear
      @received_events = ALLOWED_EVENTS.map { |ev| [ev, []] }.to_h
    end

  end
end
