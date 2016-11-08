module SessionContextSerializer
  def initialize(*)
    super

    @_session_context = SessionContextStore.get
  end

  def before
    super

    SessionContextStore.set(@_session_context)
  end
end
