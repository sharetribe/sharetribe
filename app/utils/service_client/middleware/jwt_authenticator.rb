module ServiceClient
  module Middleware

    AuthContext = EntityUtils.define_builder(
      [:marketplace_id, :uuid, :mandatory],
      [:actor_id, :uuid, :mandatory]
    )

    class JwtAuthenticator < MiddlewareBase

      def initialize(disable_authentication, token_secret)
        @_disabled = disable_authentication
        @_secret = token_secret
      end

      def enter(ctx)
        unless @_disabled
          token = create_token(ctx[:opts][:auth_context])
          ctx[:req][:headers]["Authorization"] = "Token #{token}"
        end
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
