module PaypalService
  class TestEvents
    attr_reader :received_events

    ALLOWED_EVENTS = [:request_canceled, :payment_created, :payment_updated]

    def initialize
      @received_events = ALLOWED_EVENTS.map { |ev| [ev, []] }.to_h
    end

    def send(event, payload)
      raise "Illegal event type: #{event}" unless ALLOWED_EVENTS.include? event

      @received_events[event].push(payload)
    end

  end
end
