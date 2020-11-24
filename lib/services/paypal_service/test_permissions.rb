require_relative 'test_api'

module PaypalService

  module TestPermissions
    def self.build(api_builder, store)
      PaypalService::Permissions.new(nil, TestLogger.new, TestPermissionsActions.new(store).default_test_actions, api_builder)
    end
  end

  class FakePalPermissions
    def initialize(store)
      @tokens = store.namespace(:permissions, :tokens)
      @tokens[:tokens] = @tokens[:tokens] || []
    end

    def save_permission_token(req)
      details = parse_details_from_url(req[:callback]) || {
        "email" => "payer_email@example.com",
        "payer_id" => "payer_id"
      }

      token = {
        request_token: SecureRandom.uuid,
        access_token: SecureRandom.uuid,
        access_token_secret: SecureRandom.uuid,
        email: details["email"],
        payer_id: details["payer_id"]
      }.tap { |t|
        @tokens[:tokens] = @tokens[:tokens] + [t]
      }
    end

    def parse_details_from_url(callback_url)
      query = URI.parse(callback_url).query
      if query
        hash_of_arrays = CGI.parse(query)
        HashUtils.map_values(hash_of_arrays) { |val| val.first }
      end
    end

    def by_request_token(request_token)
      @tokens[:tokens].find { |token| token[:request_token] == request_token }
    end

    def by_access_token(token:, token_secret:)
      @tokens[:tokens].find { |t| t[:access_token] == token && t[:access_token_secret] == token_secret }
    end

  end

  class TestPermissionsActions
    attr_reader :default_test_actions

    def initialize(store)
      @fake_pal = FakePalPermissions.new(store)
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
            uri = URI(req[:callback])
            redirect_url = "#{uri.scheme}://#{uri.host}#{uri.port ? ':' + uri.port.to_s : ''}#{uri.path}"
            verification_code = SecureRandom.uuid

            DataTypes::Permissions.create_req_perm_response(
              {
                username_to: api.config.subject,
                request_token: token[:request_token],
                redirect_url: "#{redirect_url}?token=#{token[:request_token]}&verification_code=#{verification_code}&request_token=#{token[:request_token]}"
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
