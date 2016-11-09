module SessionContextSerializer
  def initialize(*)
    @_session_context = SessionContextStore.get

    super if defined?(super)
  end

  def before
    SessionContextStore.set(@_session_context)

    super if defined?(super)
  end
end
