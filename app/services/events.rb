class Events

  def initialize(callbacks = {})
    @callbacks = callbacks.map { |(ev, cbs)| [ev, ensure_ary(cbs)] }.to_h
  end

  def send(event, payload)
    cbs_for_event(event).each { |cb| cb.call(payload) }
  end


  private

  def ensure_ary(el_or_ary)
    el_or_ary.is_a?(Array) ? el_or_ary : [el_or_ary]
  end

  def cbs_for_event(event)
    raise ArgumentError.new("Unknown event: #{event}") unless @callbacks.has_key? event

    @callbacks[event]
  end
end
