module ServiceClient
  module Middleware

    IDENTITY = ->() {}

    AuthContext = EntityUtils.define_builder(
      [:marketplace_id, :uuid, :mandatory],
      [:actor_id, :uuid, :mandatory]
    )

    class JwtAuthenticator < MiddlewareBase

      def initialize(secret:, default_auth_context: IDENTITY)
        @_secret = secret
        @_default_auth_context = default_auth_context
      end

      def enter(ctx)
        token = create_token(ctx[:opts][:auth_context] || @_default_auth_context.call)
        ctx[:req][:headers]["Authorization"] = "Token #{token}"

        ctx
      end

      private

      def create_token(auth_context)
        context = AuthContext.call(auth_context)
        payload = {
          marketplaceId: context[:marketplace_id],
          actorId: context[:actor_id]
        }
        JWTUtils.encode(payload, @_secret, exp: 5.minutes.from_now)
      end
    end
  end
end
