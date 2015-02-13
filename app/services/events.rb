class Events

  def initialize(callbacks = {})
    @callbacks = callbacks.map { |(ev, cbs)| [ev, Array(cbs)] }.to_h
  end

  def send(event, *payload)
    cbs_for_event(event).each { |cb| cb.call(*payload) }
  end


  private

  def cbs_for_event(event)
    raise ArgumentError.new("Unknown event: #{event}") unless @callbacks.has_key? event

    @callbacks[event]
  end
end
