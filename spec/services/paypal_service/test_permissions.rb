require_relative 'test_api'

module PaypalService

  module TestPermissions
    def self.build(api_builder)
      PaypalService::Permissions.new(nil, TestLogger.new, TestPermissionsActions.new.default_test_actions, api_builder)
    end
  end

  class FakePalPermissions
    def initialize
      @tokens = []
    end

    def save_permission_token(req)
      details = parse_details_from_url(req[:callback])

      token = {
        request_token: SecureRandom.uuid,
        access_token: SecureRandom.uuid,
        access_token_secret: SecureRandom.uuid,
        email: details["email"],
        payer_id: details["payer_id"]
      }.tap { |t|
        @tokens.push(t)
      }
    end

    def parse_details_from_url(callback_url)
      hash_of_arrays = CGI.parse(URI.parse(callback_url).query)
      HashUtils.map_values(hash_of_arrays) { |val| val.first }
    end

    def by_request_token(request_token)
      @tokens.find { |token| token[:request_token] == request_token }
    end

    def by_access_token(token:, token_secret:)
      @tokens.find { |t| t[:access_token] == token && t[:access_token_secret] == token_secret }
    end

  end

  class TestPermissionsActions
    attr_reader :default_test_actions

    def initialize
      @fake_pal = FakePalPermissions.new
      @default_test_actions = build_default_test_actions
    end

    def build_default_test_actions
      identity = -> (val) { val }
      {
        request_permissions: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.save_permission_token(req)

            DataTypes::Permissions.create_req_perm_response(
              {
                username_to: api.config.subject,
                request_token: token[:request_token],
                redirect_url: "https://paypaltest.com/?token=#{token[:request_token]}"
              })
          }
        ),
        get_access_token: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.by_request_token(req[:request_token])

            DataTypes::Permissions.create_get_access_token_response(
              {
                scope: ["TEST_SCOPE1", "TEST_SCOPE2"],
                token: token[:access_token],
                token_secret: token[:access_token_secret]
              })
          }
        ),
        get_basic_personal_data: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.by_access_token(
              token: req[:token],
              token_secret: req[:token_secret]
            )

            DataTypes::Permissions.create_get_basic_personal_data_response(
              {
                email: token[:email],
                payer_id: token[:payer_id]
              })
          }
        )
      }
    end
  end
end
