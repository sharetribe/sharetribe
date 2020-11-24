#
# This middleware stores session context to RequestStore
#
class SessionContextMiddleware

  def initialize(app)
    @app = app
  end

  def call(env)
    ::SessionContextStore.set_from_model(
      community: env[:current_marketplace],
      person: env["warden"]&.user)

    @app.call(env)
  end
end
